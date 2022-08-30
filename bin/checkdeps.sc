#!/usr/bin/env amm
// checkdeps.sc

import $ivy.`com.lihaoyi::requests:0.7.1`
import $ivy.`com.lihaoyi::ujson:2.0.0`
import $ivy.`io.kevinlee::just-semver:0.5.0`, just.semver.SemVer

/** Checks for ammonite/mill plugin updates.
  * @param path
  *   Is the path where .sc and/or .mill-version files are located
  */
def checkMill(path: os.Path = os.pwd) = {
  println(s"Checking for Ammonite/Mill plugin updates in ${Console.YELLOW}${path}${Console.RESET}")
  if (os.exists(path / ".mill-version")) {
    checkMillVersion(os.read(path / ".mill-version").trim)
  }
}

def checkMillVersion(currentVer: String) = {
  val latest =
    ujson.read(requests.get("https://api.github.com/repos/com-lihaoyi/mill/releases/latest"))("tag_name").str.trim
  if (SemVer.parse(currentVer).toOption.get < SemVer.parse(latest).toOption.get) {
    println(
      s"${Console.BOLD}Mill has updates.${Console.RESET} Currently on $currentVer, latest version: ${Console.RED}$latest.${Console.RESET} Bump your ${Console.YELLOW}.mill-version${Console.RESET} and/or ${Console.YELLOW}mill${Console.RESET} launcher script."
    )
  }
  val millver = s"${SemVer.unsafeParse(currentVer).major.value}.${SemVer.unsafeParse(currentVer).minor.value}"
}

/** Reads a .sc file
  * @param file
  *   Is the file contents to be checked
  */
def checkPluginsFile(file: os.Path) =
  // Lets read the .sc file
  if (os.exists(file)) {
    println(s"Checking plugins for: ${Console.YELLOW}${file.baseName}.${file.ext}${Console.RESET}")
    val plugins = os.read.lines(file)
    var millVer = "0.10"
    if (os.exists(file.resolveFrom(os.pwd) / ".mill-version")) {
      millVer = os.read(file.resolveFrom(os.pwd) / ".mill-version").trim
    }
    checkPluginUpdates(plugins, millVer)
  }

/** Checks for plugin updates on file.
  * @param pluginList
  *   Is the file contents to be checked
  * @param millVer
  *   The Mill version to check for plugin artifacts
  */
def checkPluginUpdates(pluginList: IndexedSeq[String], millVer: String = "0.10") = {
  // Filter plugins between ``
  val plugins = pluginList
    .flatMap("""`([^\s]+).*?`""".r.findAllMatchIn(_).toList.map(_.group(1)))
    .filter(!_.contains("MILL_VERSION"))
    .filter(""".+:+.+:.+""".r.findFirstIn(_).isDefined)
    .map(_.split(":+"))
    .map(a => Map("org" -> a(0), "artifact" -> a(1), "version" -> a(2)))
    .toArray

  // println(s"Detected plugins: $plugins")
  val scalaVer    = scalaVersion.value.split('.').take(2).mkString(".")
  val scaladexURL = "https://index.scala-lang.org"

  // Search Scaladex for matching plugins
  plugins.foreach { plugin =>
    val doc =
      ujson.read(
        requests.get(
          s"$scaladexURL/api/search?q=${plugin("artifact")}&target=JVM&scalaVersion=${scalaVer}"
        )
      )

    // Filter plugins which contain artifacts matching the plugin we need (with and without mill version)
    val filteredPlugin = doc.arr.filter { r =>
      r("artifacts").arr.toArray.contains(s"${plugin("artifact")}_mill${millVer}") || r("artifacts").arr.toArray
        .contains(plugin("artifact"))
    }

    // Print error if not found
    if (filteredPlugin.isEmpty) {
      println(
        s"  - Could not find plugin ${Console.GREEN}${plugin("org")}:${plugin("artifact")}${Console.RESET} in Scaladex ($scaladexURL)."
      )
    } else {
      // Fetch the plugin available versions
      val pluginversions = ujson.read(
        requests.get(
          s"$scaladexURL/api/project?organization=${filteredPlugin(0)("organization").str}&repository=${filteredPlugin(0)("repository").str}"
        )
      )
      if (pluginversions.toString == "[]") {
        println(
          s"Could not find versions for plugin ${Console.GREEN}${plugin("org")}:${plugin("artifact")}${Console.RESET} in Scaladex ($scaladexURL)."
        )
      }
      // Check if current version is lower than the available one
      val currentVersion = SemVer.parse(plugin("version"))
      var latestVer      = pluginversions("versions").arr.map(_.str).flatMap(SemVer.parse(_).toOption).sortWith(_ < _).last
      if (currentVersion.toOption.get < latestVer) {
        println(
          s"  - Plugin ${Console.GREEN}${plugin("org")}:${plugin(
              "artifact"
            )}${Console.RESET} has updates. Using ${currentVersion.right.get.render}. Latest version is ${Console.RED}${latestVer.render}${Console.RESET}."
        )
      }
    }
  }
}

@main
def main(path: String = os.pwd.toString()) = {
  checkMill(os.Path(path))
  os.list(os.Path(path)).filter(_.ext == "sc").foreach(checkPluginsFile(_))
}
