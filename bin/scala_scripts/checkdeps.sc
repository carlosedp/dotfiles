#!/usr/bin/env -S scala-cli shebang
// checkdeps.sc
// Install [scala-cli](https://scala-cli.virtuslab.org/) to use

//> using scala "3.3.0"
//> using dep "com.lihaoyi::os-lib:0.9.1"
//> using dep "com.lihaoyi::requests:0.8.0"
//> using dep "com.lihaoyi::ujson:3.1.0"
//> using dep "com.lihaoyi::fansi::0.4.0"
//> using dep "io.kevinlee::just-semver:0.6.0"
//> using dep "org.scala-lang.modules::scala-xml:2.2.0"

import just.semver.SemVer
import fansi.Color.*

val DEBUG = true
val SILENT = true

/** Handles mill and scala scripts plugin updates. */
object Checkdeps:
  var anyUpdates = false
  // ------------------- Handle Scala Versions ------------------------ //
  def getScalaVersion() =
    // Get latest Scala version for Scala 3
    println(s"Checking for updates in Scala versions")
    val currentScalaReq = requests.get("https://api.github.com/repos/lampepfl/dotty/releases/latest")
    val currentScala = if currentScalaReq.is2xx then
      ujson.read(currentScalaReq)("tag_name").str.trim
    else
      // Check version from other source in case Github limits API
      (scala.xml.XML.loadString(requests.get("https://repo1.maven.org/maven2/org/scala-lang/scala3-compiler_3/maven-metadata.xml").text()) \\ "release").text.trim
    println(s"  → ${Yellow("Dotty")} is currently on ${Green(currentScala)}")

    // Get latest Scala version for Scala 2.12 and 2.13
    val currentScala2Req = requests.get("https://api.github.com/repos/scala/scala/releases")

    val currentScala213 = if currentScala2Req.is2xx then
      ujson.read(currentScala2Req)
              .arr.filter(_("tag_name").str
              .contains("2.13"))
              .map(_("tag_name").str.trim
              .replace("v", ""))
              .sortWith(SemVer.parse(_).toOption.get > SemVer.parse(_).toOption.get)
              .head
    else
      // Check version from other source in case Github limits API
      val currentScala2 = scala.xml.XML.loadString(
              requests.get("https://repo1.maven.org/maven2/org/scala-lang/scala-compiler/maven-metadata.xml").text(),
            )
            val latest212 = currentScala2 \ "versioning" \ "versions" \ "version"
            latest212
              .map(_.text)
              .filter(_.startsWith("2.13"))
              .sortWith(SemVer.parse(_).toOption.get > SemVer.parse(_).toOption.get)
              .head
    println(s"  → ${Yellow("Scala 2.13")} is currently on ${Green(currentScala213)}")

    val currentScala212 = if currentScala2Req.is2xx then
      // Get all releases and filter for 2.12
      ujson.read(currentScala2Req)
        .arr.filter(_("tag_name").str
        .contains("2.12"))
        .map(_("tag_name").str.trim
        .replace("v", ""))
        .sortWith(SemVer.parse(_).toOption.get > SemVer.parse(_).toOption.get)
        .head
    else
      // Check version from other source in case Github limits API
      val currentScala2 = scala.xml.XML.loadString(
        requests.get("https://repo1.maven.org/maven2/org/scala-lang/scala-compiler/maven-metadata.xml").text(),
      )
      val latest212 = currentScala2 \ "versioning" \ "versions" \ "version"
      latest212
        .map(_.text)
        .filter(_.startsWith("2.12"))
        .sortWith(SemVer.parse(_).toOption.get > SemVer.parse(_).toOption.get)
        .head
    println(s"  → ${Yellow("Scala 2.12")} is currently on ${Green(currentScala212)}")

    val millout = os.proc("./mill", "show", "__.scalaVersion").call(stdout = os.Pipe, check = false)
    if millout.exitCode == 0 then
      val scalaVers = ujson.read(millout.out.trim())
      scalaVers.obj.foreach { case (k, v) =>
        // Check which Scala version is used
        v.str.replace("\"", "") match
          case ver if ver.startsWith("2.12") => if ver != currentScala212 then
            println(s"    ↳ Project \"${Yellow(k)}\" is outdated (${Red(v.str)}). Current version is ${Green(currentScala212)}")
            anyUpdates = true
          case ver if ver.startsWith("2.13") => if ver != currentScala213 then
            println(s"    ↳ Project \"${Yellow(k)}\" is outdated (${Red(v.str)}). Current version is ${Green(currentScala213)}")
            anyUpdates = true
          case ver if ver.startsWith("3") => if ver != currentScala then
            println(s"    ↳ Project \"${Yellow(k)}\" is outdated (${Red(v.str)}). Current version is  ${Green(currentScala)}")
            anyUpdates = true
          case _ =>
            println("    ↳ " + Red("Could not parse Scala version for " + k + ""))
    }
    // Check Scala Native
    val scalaNative = ujson.read(requests.get("https://api.github.com/repos/scala-native/scala-native/releases/latest"))("tag_name").str.trim.replace("v", "")
    println(s"  → ${Yellow("Scala Native")} is currently on ${Green(scalaNative)}")
    val milloutNative = os.proc("./mill", "show", "__.scalaNativeVersion").call(check = false)
    if milloutNative.exitCode == 0 then
      val projectScalaNativeVer = milloutNative.out.trim().replace("v", "")
      // println(s"  → Project uses Scala Native ${Green(projectScalaNativeVer)}")
      if projectScalaNativeVer.replace("\"","") != scalaNative then
        println(s"    ↳ Project uses Scala Native ${Red(projectScalaNativeVer)} which is outdated. Current version is ${Green(scalaNative)}")
        anyUpdates = true

    // Check Scala.js
    val scalaJS = ujson.read(requests.get("https://api.github.com/repos/scala-js/scala-js/releases/latest"))("tag_name").str.trim.replace("v", "")
    println(s"  → ${Yellow("Scala.js")} is currently on ${Green(scalaJS)}")
    val milloutJS = os.proc("./mill", "show", "__.scalaJSVersion").call(stdout = os.Pipe, check = false)
    if milloutJS.exitCode == 0 then
      val projectScalaJSVer = milloutJS.out.trim().replace("v", "")
      // println(s"  → Project uses Scala.js ${Green(projectScalaJSVer)}")
      if projectScalaJSVer.replace("\"","") != scalaJS then
        println(s"    ↳ Project uses Scala.js ${Red(projectScalaJSVer)} which is outdated. Current version is ${Green(scalaJS)}")
        anyUpdates = true


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
    val latestMillGH = requests.get("https://api.github.com/repos/com-lihaoyi/mill/releases/latest")
    val latest = if latestMillGH.is2xx then
      ujson.read(latestMillGH)("tag_name").str.trim
    else
      // Alternative source in case Github limits API
      (scala.xml.XML.loadString(requests.get("https://repo1.maven.org/maven2/com/lihaoyi/mill-main_2.13/maven-metadata.xml").text()) \\ "release").text.trim

    if SemVer.parse(currentVer).toOption.get < SemVer.parse(latest).toOption.get then
      anyUpdates = true
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
        s"    ↳ ✗ ${Red("Could not find the plugin or versions")} for plugin ${Green(pluginName)} in Scaladex ($scaladexURL)."
      )

    // Check if current version is lower than the available one
    val currentVersion = SemVer.parse(plugin("version")) match
      case Left(value) =>
        return Some(s"    ↳ ✗ ${Red("Could not parse current version for ")} ${Green(pluginName)}. (${Red(value.render)})")
      case Right(value) => value

    val latestVer =
      doc("items").arr.map(_("version")).toArray.map(_.str).flatMap(SemVer.parse(_).toOption).sortWith(_ < _).last
    val ret = if currentVersion < latestVer then
      anyUpdates = true
      Some(s"    ↳ ${Green(pluginName)} has updates. Using ${Red(currentVersion.render)}. Latest version is ${Green(latestVer.render)}.")
    else if !SILENT then Some(s"    ↳ ✓ ${Green(pluginName)} is already up-to-date.") else None
    return ret

// Run the script
def main(args: Array[String]): Unit =
  val path = if args.mkString != "" then os.Path(args.mkString) else os.pwd
  // Check Scala version
  if os.exists(path / "build.sc") then
    Checkdeps.getScalaVersion()

  // Check Mill version
  println(s"Checking for updates in Ammonite/Mill plugins/libs in ${Yellow(path.toString)}")
  if os.exists(path / ".mill-version") then
    Checkdeps.getMillVersion(os.read(path / ".mill-version").trim) match
      case Some(msg) =>
        println(msg)
      case None      =>

  // Check mill plugins
  os.list(path).filter(f => f.ext == "sc" || f.ext == "scala").foreach(Checkdeps.checkPlugins(_))
  // Print message if no updates are found
  if !Checkdeps.anyUpdates then
    println(s"${Green("✓")} All plugins and libs are up-to-date.")
  else
    println(s"${Red("✗")} Some plugins and/or libs are outdated.")

main(args)
