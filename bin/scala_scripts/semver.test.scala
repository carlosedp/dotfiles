// SemVer.test.scala
// Install [scala-cli](https://scala-cli.virtuslab.org/) to use
// Run with scli test semver.test.scala
//> using scala "2.13"
//> using lib "org.scalameta::munit::1.0.0-M6"
//> using file "semver.sc"

import munit.FunSuite
import semver._

class SemVerSpec extends FunSuite {
  test("validate main method")(assertEquals(cmdLine(Array("1.2.3", "major")), "2.0.0"))

  test("bump major version, no minor/patch")(assertEquals(SemVer("1", BumpMode.Major), "2"))
  test("bump major version, no patch")(assertEquals(SemVer("1.2", BumpMode.Major), "2.0"))
  test("bump minor version, no patch")(assertEquals(SemVer("1.2", BumpMode.Minor), "1.3"))

  test("bump major version")(assertEquals(SemVer("1.2.3", BumpMode.Major), "2.0.0"))
  test("bump minor version")(assertEquals(SemVer("1.2.3", BumpMode.Minor), "1.3.0"))
  test("bump patch version")(assertEquals(SemVer("1.2.3", BumpMode.Patch), "1.2.4"))
  test("bump major not reseting minor and patch to zero")(
    assertEquals(SemVer("1.2.3", BumpMode.Major, reset = false), "2.2.3"),
  )
  test("bump minor not reseting patch to zero")(assertEquals(SemVer("1.2.3", BumpMode.Minor, reset = false), "1.3.3"))
  test("bump patch not reseting")(assertEquals(SemVer("1.2.3", BumpMode.Patch, reset = false), "1.2.4"))
  test("bump no version, adds SNAPSHOT")(assertEquals(SemVer("1.2.3", BumpMode.None, snap = true), "1.2.3-SNAPSHOT"))
  test("bump minor not adding SNAPSHOT")(assertEquals(SemVer("1.2.3", BumpMode.Minor, snap = true), "1.3.0-SNAPSHOT"))
  test("bump major stripping minor and patch")(
    assertEquals(SemVer("1.2.3", BumpMode.Major, strip = true), "2"),
  )
  test("bump major stripping minor and patch adding SNAPSHOT")(
    assertEquals(SemVer("1.2.3", BumpMode.Major, strip = true, snap = true), "2-SNAPSHOT"),
  )
  test("bump minor stripping patch")(assertEquals(SemVer("1.2.3", BumpMode.Minor, strip = true), "1.3"))
  test("bump patch stripping (no change)")(
    assertEquals(SemVer("1.2.3", BumpMode.Patch, strip = true), "1.2.4"),
  )
  test("bump minor stripping patch without adding SNAPSHOT") {
    assertEquals(SemVer("1.2.3", BumpMode.Minor, snap = true, strip = true), "1.3-SNAPSHOT")
  }
  test("bump minor adding SNAPSHOT keeping pre and meta data") {
    assertEquals(SemVer("1.2.3-build3+10", BumpMode.Minor, snap = true), "1.3.0-build3+10-SNAPSHOT")
  }
  test("bump minor striping patch, adding SNAPSHOT keeping pre and meta data") {
    assertEquals(SemVer("1.2.3-build3+10", BumpMode.Minor, strip = true, snap = true), "1.3-build3+10-SNAPSHOT")
  }
  test("bump minor without SNAPSHOT, stripping patch, keeping pre and meta data") {
    assertEquals(SemVer("1.2.3-build3+10", BumpMode.Minor, strip = true), "1.3-build3+10")
  }
}
