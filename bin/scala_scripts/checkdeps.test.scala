// checkdeps.test.scala
// Install [scala-cli](https://scala-cli.virtuslab.org/)
// Test with `scala-cli test checkdeps.test.scala`

//> using scala "3"
//> using lib "com.lihaoyi::utest:0.8.0"
//> using lib "io.kevinlee::just-semver:0.5.0"
//> using file "checkdeps.sc"

import utest._
import just.semver.SemVer
import checkdeps.Checkdeps._

object CheckDepsTests extends TestSuite:
  val tests = Tests {
    test("Mill") {
      test("check Mill version with update") {
        val data = getMillVersion("0.10.1")
        assert(!data.get.isEmpty())
        assert(data.get.contains("Mill has updates"))
      }

      test("check Mill version without update") {
        val current =
          ujson.read(requests.get("https://api.github.com/repos/com-lihaoyi/mill/releases/latest"))("tag_name").str.trim
        val d = getMillVersion(current)
        assert(d.isEmpty)
      }
    }

    test("Plugins") {
      test("Parsing") {
        test("check plugin parsing for single line import") {
          val testData = """
            // Some comment
            import $ivy.`io.github.davidgregory084::mill-tpolecat::0.3.1`
            """.stripMargin.split("\n").toIndexedSeq
          val p = getPlugins(testData)
          assert(
            p.contains(Map("org" -> "io.github.davidgregory084", "artifact" -> "mill-tpolecat", "version" -> "0.3.1")),
          )
        }

        test("check plugin parsing for single line import with two plugins") {
          val testData = """
            // Some comment
            import $ivy.{`com.lihaoyi::requests:0.2.0 compat`, `com.lihaoyi::ujson:0.7.5 compat`}
            """.stripMargin.split("\n").toIndexedSeq
          val p = getPlugins(testData)
          assert(
            p.contains(Map("org" -> "com.lihaoyi", "artifact" -> "requests", "version" -> "0.2.0")),
            p.contains(Map("org" -> "com.lihaoyi", "artifact" -> "ujson", "version" -> "0.7.5")),
          )
        }

        test("check plugin parsing for single import with two plugins") {
          val testData = """
            // Some comment
            import $ivy.{
              `com.lihaoyi::requests:0.2.0 compat`,
              `com.lihaoyi::ujson:0.7.5 compat`
            }
            """.stripMargin.split("\n").toIndexedSeq
          val p = getPlugins(testData)
          assert(
            p.contains(Map("org" -> "com.lihaoyi", "artifact" -> "requests", "version" -> "0.2.0")),
            p.contains(Map("org" -> "com.lihaoyi", "artifact" -> "ujson", "version" -> "0.7.5")),
          )
        }

        test("check plugin parsing ivy and plugin import the same line") {
          val testData = """
            // Some comment
            import $ivy.`com.goyeau::mill-scalafix::0.2.9`, com.goyeau.mill.scalafix.ScalafixModule
            """.stripMargin.split("\n").toIndexedSeq
          val p = getPlugins(testData)
          assert(
            p.contains(Map("org" -> "com.goyeau", "artifact" -> "mill-scalafix", "version" -> "0.2.9")),
          )
        }

        test("check plugin parsing for scala-cli using style") {
          val testData = """
            // Some comment
            //> using lib "io.kevinlee::just-semver:0.5.0"
            """.stripMargin.split("\n").toIndexedSeq
          val p = getPlugins(testData)
          assert(
            p.contains(Map("org" -> "io.kevinlee", "artifact" -> "just-semver", "version" -> "0.5.0")),
          )
        }
      }
      test("Updates") {
        test("check plugin with no update") {
          // Lets get the plugin versions
          val pluginversions = ujson.read(
            requests.get(
              s"https://index.scala-lang.org/api/project?organization=joan38&repository=mill-scalafix",
            ),
          )
          // now get the latest version
          var latestVer =
            pluginversions("versions").arr.map(_.str).flatMap(SemVer.parse(_).toOption).sortWith(_ < _).last
          // and check against it
          val testData = raw"""
                   import $$ivy.`com.goyeau::mill-scalafix::${latestVer.render}`
                   """.stripMargin.split("\n").toIndexedSeq
          val p = getPlugins(testData)
          assert(
            p.contains(Map("org" -> "com.goyeau", "artifact" -> "mill-scalafix", "version" -> latestVer.render)),
          )
          // to make sure we don't show updates
          assert(getPluginUpdates(p(0)).isEmpty)
        }
        test("check plugin with update") {
          val testData = """
                   // Some comment
                   import $ivy.`io.github.davidgregory084::mill-tpolecat::0.3.0`
                   """.stripMargin.split("\n").toIndexedSeq
          val p = getPlugins(testData)
          val d = getPluginUpdates(p(0)).get
          assert(d.contains("has updates"))
        }
      }
    }
  }
