// SemVer.test.scala
// Install [scala-cli](https://scala-cli.virtuslab.org/) to use
// Run with scli test semver.test.scala
//> using scala "2.13"
//> using lib "com.lihaoyi::utest:0.8.0"
//> using file "semver.sc"

import utest._
import semver._

object SemVerTests extends TestSuite {
  val tests = Tests {
    test("bump major version")(assert(SemVer("1.2.3", BumpMode.Major) == "2.2.3-SNAPSHOT"))
    test("bump minor version")(assert(SemVer("1.2.3", BumpMode.Minor) == "1.3.3-SNAPSHOT"))
    test("bump patch version")(assert(SemVer("1.2.3", BumpMode.Patch) == "1.2.4-SNAPSHOT"))
    test("bump major reseting minor and patch to zero")(
      assert(SemVer("1.2.3", BumpMode.Major, reset = true) == "2.0.0-SNAPSHOT"),
    )
    test("bump minor reseting patch to zero")(assert(SemVer("1.2.3", BumpMode.Minor, reset = true) == "1.3.0-SNAPSHOT"))
    test("bump patch reseting (no change)")(assert(SemVer("1.2.3", BumpMode.Patch, reset = true) == "1.2.4-SNAPSHOT"))
    test("bump no version, adds SNAPSHOT")(assert(SemVer("1.2.3", BumpMode.None) == "1.2.3-SNAPSHOT"))
    test("bump minor not adding SNAPSHOT")(assert(SemVer("1.2.3", BumpMode.Minor, snap = false) == "1.3.3"))
    test("bump major stripping minor and patch")(assert(SemVer("1.2.3", BumpMode.Major, strip = true) == "2-SNAPSHOT"))
    test("bump minor stripping patch")(assert(SemVer("1.2.3", BumpMode.Minor, strip = true) == "1.3-SNAPSHOT"))
    test("bump patch stripping (no change)")(assert(SemVer("1.2.3", BumpMode.Patch, strip = true) == "1.2.4-SNAPSHOT"))
    test("bump minor stripping patch without adding SNAPSHOT") {
      assert(SemVer("1.2.3", BumpMode.Minor, snap = false, strip = true) == "1.3")
    }
    test("bump minor adding SNAPSHOT keeping pre and meta data") {
      assert(SemVer("1.2.3-build3+10", BumpMode.Minor) == "1.3.3-build3+10-SNAPSHOT")
    }
    test("bump minor striping patch, adding SNAPSHOT keeping pre and meta data") {
      assert(SemVer("1.2.3-build3+10", BumpMode.Minor, strip = true) == "1.3-build3+10-SNAPSHOT")
    }
    test("bump minor without SNAPSHOT, stripping patch, keeping pre and meta data") {
      assert(SemVer("1.2.3-build3+10", BumpMode.Minor, snap = false, strip = true) == "1.3-build3+10")
    }
  }
}
