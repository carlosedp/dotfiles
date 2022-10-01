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
    *   strips version fields after the one being bumped
    * @param reset
    *   resets to `0` version fields after the one being bumped
    *
    * @return
    *   a string with modified SemVer
    */
  def apply(
    version:  String,
    bumpMode: BumpMode.Mode,
    snap:     Boolean = true,
    strip:    Boolean = false,
    reset:    Boolean = false,
  ): String = {
    val VersionR                                 = """(?:v?)(\d+)\.(\d+)\.(\d+)(?:(-[a-zA-Z\d-\.]+)?)?(?:(\+[a-zA-Z\d-\.]+)?)?""".r
    var VersionR(major, minor, patch, pre, meta) = version: @unchecked
    val ver = bumpMode match {
      case BumpMode.Major =>
        if (reset) { minor = "0"; patch = "0" };
        if (!strip) s"${major.toInt + 1}.$minor.$patch" else s"${major.toInt + 1}"
      case BumpMode.Minor =>
        if (reset) { patch = "0" }; if (!strip) s"$major.${minor.toInt + 1}.$patch" else s"$major.${minor.toInt + 1}"
      case BumpMode.Patch => s"$major.$minor.${patch.toInt + 1}"
      case BumpMode.None  => s"$major.$minor.$patch"
    }
    (ver + (if (pre != null) pre else "") + (if (meta != null) meta else "") + (if (snap) "-SNAPSHOT" else "")).trim
  }
}

// Usage:
val _ = SemVer("1.2.3", BumpMode.Major)                                       // => 2.2.3-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Minor)                                       // => 1.3.3-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Patch)                                       // => 1.2.4-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Major, reset = true)                         // => 2.0.0-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Minor, reset = true)                         // => 1.3.0-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Patch, reset = true)                         // => 1.2.4-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.None)                                        // => 1.2.3-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Minor, snap = false)                         // => 1.3.3
val _ = SemVer("1.2.3", BumpMode.Major, strip = true)                         // => 2-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Minor, strip = true)                         // => 1.3-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Patch, strip = true)                         // => 1.2.4-SNAPSHOT
val _ = SemVer("1.2.3", BumpMode.Minor, snap = false, strip = true)           // => 1.3
val _ = SemVer("1.2.3-build3+10", BumpMode.Minor)                             // => 1.3.3-build3+10-SNAPSHOT
val _ = SemVer("1.2.3-build3+10", BumpMode.Minor, strip = true)               // => 1.3-build3+10-SNAPSHOT
val _ = SemVer("1.2.3-build3+10", BumpMode.Minor, snap = false, strip = true) // => 1.3-build3+10
