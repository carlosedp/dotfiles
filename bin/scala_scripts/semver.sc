#!/usr/bin/env -S scala-cli shebang
// SemVer.sc
// Install [scala-cli](https://scala-cli.virtuslab.org/) to use
//> using scala "2.13"

/** SemVer bump mode type
  */
object BumpMode extends Enumeration {
  type Mode = Value
  val Major, Minor, Patch, None = Value
}

object SemVer {

  /** Creates a new [[SemVer]] with bump and manipulation
    *
    * @param version
    *   the input SemVer string
    * @param bumpMode
    *   [[BumpMode.Mode]] to which version field to bump. `Major`, `Minor`, `Patch` or `None`
    * @param snap
    *   append `-SNAPSHOT` to generated version (defaults to `true`)
    * @param strip
    *   strips version fields after the one being bumped. Eg. "1.2.3" with Bump.Minor becomes "1.3"
    * @param reset
    *   resets to `0` version fields after the one being bumped. Eg. "1.2.3" with Bump.Minor becomes "1.3.0"
    *
    * @return
    *   a string with modified SemVer
    */
  def apply(
    version:  String,
    bumpMode: BumpMode.Mode,
    snap:     Boolean = false,
    strip:    Boolean = false,
    reset:    Boolean = true,
  ): String = {
    val VersionR = """(?:v?)(\d+)\.?(?:([\d]+))?\.?(?:([\d]+))?(?:(-[a-zA-Z\d-\.]+)?)?(?:(\+[a-zA-Z\d-\.]+)?)?""".r

    def ifSet(v: String, optVal: String = ""): String = if (v != null) if (optVal.nonEmpty) optVal else v else ""

    val VersionR(major, minor, patch, pre, meta) = version: @unchecked

    val newVersion = bumpMode match {
      case BumpMode.Major =>
        if (!strip) {
          (major.toInt + 1).toString() + ifSet(minor, s".${if (!reset) minor else 0}") + ifSet(
            patch,
            s".${if (!reset) patch else 0}",
          )
        } else s"${major.toInt + 1}"
      case BumpMode.Minor =>
        if (!strip) {
          major + s".${minor.toInt + 1}" + ifSet(patch, s".${if (!reset) patch else 0}")
        } else s"$major.${minor.toInt + 1}"
      case BumpMode.Patch => s"$major.$minor.${patch.toInt + 1}"
      case BumpMode.None  => s"$major.$minor.$patch"
    }
    (newVersion + ifSet(pre) + ifSet(meta) + (if (snap) "-SNAPSHOT" else "")).trim
  }
}

def cmdLine(args: Array[String]) =
  if (args.length >= 1) {
    val bumpmode = if (args.length >= 2) {
      args(1) match {
        case "major" => BumpMode.Major
        case "minor" => BumpMode.Minor
        case "patch" => BumpMode.Patch
        case _       => BumpMode.None
      }
    } else BumpMode.None
    SemVer(args(0), bumpmode)
  } else { "Pass a SemVer as argument" }

println(cmdLine(args))

// Usage:rg
// val _ = SemVer("1.2.3", BumpMode.Major)                                       // => 2.0.0
// val _ = SemVer("1", BumpMode.Major)                                           // => 2
// val _ = SemVer("1.2.3", BumpMode.Minor)                                       // => 1.3.0
// val _ = SemVer("1.2", BumpMode.Minor)                                         // => 1.3
// val _ = SemVer("1.2.3", BumpMode.Patch)                                       // => 1.2.4
// val _ = SemVer("1.2.3", BumpMode.Major, reset = false)                        // => 2.2.3
// val _ = SemVer("1.2.3", BumpMode.Minor, reset = false)                        // => 1.3.3
// val _ = SemVer("1.2.3", BumpMode.Patch, reset = false)                        // => 1.2.4
// val _ = SemVer("1.2.3", BumpMode.None)                                        // => 1.2.3
// val _ = SemVer("1.2.3", BumpMode.Minor, snap = true)                          // => 1.3.3-SNAPSHOT
// val _ = SemVer("1.2.3", BumpMode.Major, strip = true)                         // => 2
// val _ = SemVer("1.2.3", BumpMode.Minor, strip = true)                         // => 1.3-SNAPSHOT
// val _ = SemVer("1.2.3", BumpMode.Patch, snap = true)                          // => 1.2.4-SNAPSHOT
// val _ = SemVer("1.2.3", BumpMode.Minor, snap = true, strip = true)            // => 1.3-SNAPSHOT
// val _ = SemVer("1.2.3-build3+10", BumpMode.Minor, snap = true)                // => 1.3.0-build3+10-SNAPSHOT
// val _ = SemVer("1.2.3-build3+10", BumpMode.Minor)                             // => 1.3-build3+10
// val _ = SemVer("1.2.3-build3+10", BumpMode.Minor, strip = false, snap = true) // => 1.3.0-build3+10-SNAPSHOT
