#!/usr/bin/env -S scala-cli shebang
// checkdeps.sc
// Install [scala-cli](https://scala-cli.virtuslab.org/) to use

//> using scala "3.3.0-RC5"
//> using dep "com.lihaoyi::os-lib:0.9.1"
//> using dep "com.lihaoyi::requests:0.8.0"
//> using dep "com.lihaoyi::ujson:3.1.0"
//> using dep "com.lihaoyi::fansi::0.4.0"
//> using dep "io.kevinlee::just-semver:0.6.0"

import just.semver.SemVer
import fansi.Color.*

val DEBUG = true
val SILENT = true

/** Handles mill and scala scripts plugin updates. */
object Checkdeps:

  // ------------------- Handle Mill Versions ------------------------ //
  /**
   * Checks for mill updates.
   * @param path
   *   Is the path where `.sc` and/or `.mill-version` files are located
   */
  def checkMill(path: os.Path = os.pwd): Unit =
    println(s"Checking for updates in Ammonite/Mill plugins/libs in ${Yellow(path.toString)}")
    if os.exists(path / ".mill-version") then
      getMillVersion(os.read(path / ".mill-version").trim) match
        case Some(msg) => println(msg)
        case None      =>

  /**
   * Compares the current version with latest release
   *
   * @param currentVer
   *   Is the current version defined in `.mill-version`
   * @return
   *   an `Option[String]` with the update message or `None` if no updates are
   *   available
   */
  def getMillVersion(currentVer: String): Option[String] =
    val latest =
      ujson.read(requests.get("https://api.github.com/repos/com-lihaoyi/mill/releases/latest"))("tag_name").str.trim
    if SemVer.parse(currentVer).toOption.get < SemVer.parse(latest).toOption.get then
      Some(
        s"${fansi.Bold.On("Mill has updates.")} Currently on $currentVer, latest version: ${Red(latest)}. Bump your ${Yellow(".mill-version")} and/or ${Yellow("mill")} launcher script."
      )
    else None

// ------------------- Handle Plugin Versions ------------------------ //

  /**
   * Checks for updates on scala plugin files (`.sc`). The script supports both
   * `$ivy` and scala-cli `//> using` styles. For more supported styles, check
   * the tests
   *
   * @param file
   *   is the file to be checked
   */
  def checkPlugins(file: os.Path): Unit =
    if os.exists(file) then
      val data = loadFile(file)
      val p    = getPlugins(data)
      p.foreach: plugin =>
        if DEBUG then println(s"  → ${plugin("artifact")}")
        val isMill = if file.baseName == "build" then true else false
        getPluginUpdates(plugin, isMill = isMill) match
          case Some(msg) => println(msg)
          case None      =>

  /**
   * Reads a .sc file and returns the file lines
   * @param file
   *   Is the file contents to be checked
   * @return
   *   an `IndexedSeq[String] containing the file lines
   */
  def loadFile(file: os.Path): IndexedSeq[String] =
    // Lets read the .sc file
    println(s"Checking plugins and libs for: " + Yellow(s"${file.baseName}.${file.ext}"))
    os.read.lines(file)

  /**
   * Gets the plugins matching pattern
   * @param pluginList
   *   Is the file contents to be checked
   * @return
   *   an array of maps in the format `Map("org" -> "com.lihaoyi", "artifact" ->
   *   "requests", "version" -> "0.2.0")` containing each identified plugin.
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

  /**
   * Checks for plugin update
   * @param plugin
   *   Is map containing plugin org, artifact and current version
   * @param millVer
   *   Is the mill version used to check for the artifact
   * @return
   *   an `Option[String]` with a message if the plugin has updates or if there
   *   was an error checking. Could also be `None` if no update is found.
   */
  def getPluginUpdates(
    plugin:   Map[String, String],
    millVer:  String = "0.10",
    scalaVer: String = "2.13",
    isMill:   Boolean = false
  ): Option[String] =
    val scaladexURL = "https://index.scala-lang.org"

    // Search Scaladex for plugin
    val url = if isMill then s"$scaladexURL/api/artifacts/${plugin("org")}/${plugin("artifact")}_mill${millVer}_${scalaVer}" else
    s"$scaladexURL/api/artifacts/${plugin("org")}/${plugin("artifact")}_${scalaVer}"

    val doc = ujson.read(requests.get(url))

    val pluginName = s"${plugin("org")}:${plugin("artifact")}"
    if doc("items").arr.isEmpty then
      return Some(
        s"   ✗ ${Red("Could not find the plugin or versions")} for plugin ${Green(pluginName)} in Scaladex ($scaladexURL)."
      )

    // Check if current version is lower than the available one
    val currentVersion = SemVer.parse(plugin("version")) match
      case Left(value) => return Some(s"   ✗ ${Red("Could not parse current version for ")} ${Green(pluginName)}")
      case Right(value) => value

    val latestVer =
      doc("items").arr.map(_("version")).toArray.map(_.str).flatMap(SemVer.parse(_).toOption).sortWith(_ < _).last
    val ret = if currentVersion < latestVer then
      Some(s"   ↳ ${Green(pluginName)} has updates. Using ${currentVersion.render}. Latest version is ${Red(latestVer.render)}.")
    else if !SILENT then Some(s"   ✓ ${Green(pluginName)} is already up-to-date.") else None
    return ret

// Run the script
val path = if args.mkString != "" then args.mkString else os.pwd.toString
Checkdeps.checkMill(os.Path(path))
os.list(os.Path(path)).filter(f => f.ext == "sc" || f.ext == "scala").foreach(Checkdeps.checkPlugins(_))
