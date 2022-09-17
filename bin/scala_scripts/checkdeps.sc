#!/usr/bin/env -S scala-cli shebang
// checkdeps.sc
// Install [scala-cli](https://scala-cli.virtuslab.org/) to use

//> using scala "3.nightly"
//> using lib "com.lihaoyi::os-lib:0.8.1"
//> using lib "com.lihaoyi::requests:0.7.1"
//> using lib "com.lihaoyi::ujson:2.0.0"
//> using lib "com.lihaoyi::fansi::0.4.0"
//> using lib "io.kevinlee::just-semver:0.5.0"

import language.experimental.fewerBraces
import just.semver.SemVer

/** Handles mill and scala scripts plugin updates. */
object Checkdeps:

// ------------------- Handle Mill Versions ------------------------ //

  /** Checks for mill updates.
    * @param path
    *   Is the path where `.sc` and/or `.mill-version` files are located
    */
  def checkMill(path: os.Path = os.pwd) =
    println(s"Checking for Ammonite/Mill plugin updates in ${fansi.Color.Yellow(path.toString)}")
    if os.exists(path / ".mill-version") then
      getMillVersion(os.read(path / ".mill-version").trim) match
        case Some(msg) => println(msg)
        case None      =>

  /** Compares the current version with latest release
    *
    * @param currentVer
    *   Is the current version defined in `.mill-version`
    * @return
    *   an `Option[String]` with the update message or `None` if no updates are available
    */
  def getMillVersion(currentVer: String): Option[String] =
    val latest =
      ujson.read(requests.get("https://api.github.com/repos/com-lihaoyi/mill/releases/latest"))("tag_name").str.trim
    if SemVer.parse(currentVer).toOption.get < SemVer.parse(latest).toOption.get then
      Some(
        s"${fansi.Bold.On("Mill has updates.")} Currently on $currentVer, latest version: ${fansi.Color
            .Red(latest)}. Bump your ${fansi.Color.Yellow(".mill-version")} and/or ${fansi.Color.Yellow("mill")} launcher script.",
      )
    else None

// ------------------- Handle Plugin Versions ------------------------ //

  /** Checks for updates on scala plugin files (`.sc`). The script supports both `$ivy` and scala-cli `//> using`
    * styles. For more supported styles, check the tests
    *
    * @param file
    *   is the file to be checked
    */
  def checkPlugins(file: os.Path) =
    if os.exists(file) then
      val data = loadFile(file)
      val p    = getPlugins(data)
      p.foreach: plugin =>
        getPluginUpdates(plugin) match
          case Some(msg) => println(msg)
          case None      =>

  /** Reads a .sc file and returns the file lines
    * @param file
    *   Is the file contents to be checked
    * @return
    *   an `IndexedSeq[String] containing the file lines
    */
  def loadFile(file: os.Path): IndexedSeq[String] =
    // Lets read the .sc file
    println(s"Checking plugins for: " + fansi.Color.Yellow(s"${file.baseName}.${file.ext}"))
    os.read.lines(file)

  /** Gets the plugins matching pattern
    * @param pluginList
    *   Is the file contents to be checked
    * @return
    *   an array of maps in the format `Map("org" -> "com.lihaoyi", "artifact" -> "requests", "version" -> "0.2.0")`
    *   containing each identified plugin.
    */
  def getPlugins(pluginList: IndexedSeq[String]): Array[Map[String, String]] =
    // Filter plugins between ``
    pluginList
      .flatMap("""(?:\`|.*using lib \")([^\s]+).*?(?:\`|\".*)""".r.findAllMatchIn(_).toList.map(_.group(1)))
      .filter(!_.contains("MILL_VERSION"))
      .filter(""".+:+.+:.+""".r.findFirstIn(_).isDefined)
      .map(_.split(":+"))
      .map(a => Map("org" -> a(0), "artifact" -> a(1), "version" -> a(2)))
      .toArray

  /** Checks for plugin update
    * @param plugin
    *   Is map containing plugin org, artifact and current version
    * @param millVer
    *   Is the mill version used to check for the artifact
    * @return
    *   an `Option[String]` with a message if the plugin has updates or if there was an error checking. Could also be
    *   `None` if no update is found.
    */
  def getPluginUpdates(plugin: Map[String, String], millVer: String = "0.10"): Option[String] =
    // println(s"Detected plugins: ${plugins.mkString(" ")}")
    // val scalaVer    = scalaVersion.value.split('.').take(2).mkString(".")
    val scalaVer    = "2.13" // As most plugins are published for scala 2.13
    val scaladexURL = "https://index.scala-lang.org"

    // Search Scaladex for matching plugins

    val doc =
      ujson.read(
        requests.get(
          s"$scaladexURL/api/search?q=${plugin("artifact")}&target=JVM&scalaVersion=${scalaVer}",
        ),
      )

    val pluginName = s"${plugin("org")}:${plugin("artifact")}"
    // Filter plugins which contain artifacts matching the plugin we need (with and without mill version)
    val filteredPlugin = doc.arr.filter: r =>
      val art = r("artifacts").arr.toArray
      art.contains(s"${plugin("artifact")}_mill${millVer}") || art.contains(plugin("artifact"))

    if filteredPlugin.isEmpty then
      // Print error if not found
      return Some(
        s"  - ${fansi.Color.Red("Could not find")} plugin ${fansi.Color.Green(pluginName)} in Scaladex ($scaladexURL).",
      )
    else
      // Fetch the plugin available versions
      val pluginversions = ujson.read(
        requests.get(
          s"$scaladexURL/api/project?organization=${filteredPlugin(0)("organization").str}&repository=${filteredPlugin(0)("repository").str}",
        ),
      )
      if pluginversions.toString == "[]" then
        return Some(
          s" ${fansi.Color.Red("Could not find versions")} for plugin ${fansi.Color.Green(pluginName)} in Scaladex ($scaladexURL).",
        )

      // Check if current version is lower than the available one
      val currentVersion = SemVer.parse(plugin("version")).toOption.get
      var latestVer      = pluginversions("versions").arr.map(_.str).flatMap(SemVer.parse(_).toOption).sortWith(_ < _).last

      if currentVersion < latestVer then
        return Some(
          s"  - Plugin ${fansi.Color.Green(pluginName)} has updates. Using ${currentVersion.render}. Latest version is ${fansi.Color
              .Red(latestVer.render)}.",
        )
      else return None


// Run the script
val path = if args.mkString != "" then args.mkString else os.pwd.toString
Checkdeps.checkMill(os.Path(path))
os.list(os.Path(path)).filter(_.ext == "sc").foreach(Checkdeps.checkPlugins(_))
