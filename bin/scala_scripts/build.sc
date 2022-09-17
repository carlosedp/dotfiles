import mill._

// -------- Create each script  module below ----------- //
object template  extends ScalaScript
object checkdeps extends ScalaScript

/** A trait defining some default tasks for Scala Scripts
  */
trait ScalaScript extends Module {
  def scriptName: String = this.toString
  def millSourcePath = super.millSourcePath / os.up
  def scriptSource   = T.sources(os.pwd / s"$scriptName.sc")

  def run(args: String = "") = T.command {
    os
      .proc(
        "scala-cli",
        "run",
        scriptSource().map(_.path.toString()),
        "--",
        args.split(" "),
      )
      .call(stdout = os.Inherit, stderr = os.Inherit)
  }

  def native = T {
    println(s"Building native binary for $scriptName")
    os
      .proc(
        "scala-cli",
        "package",
        "-f",
        "--native-image",
        scriptSource().map(_.path.toString()),
        "-o",
        scriptName,
        "--",
        "--enable-url-protocols=https",
      )
      .call(stdout = os.Inherit)
    println(s"Compressing binary $scriptName with UPX")
    os.proc("upx", "-9", scriptName).call(stdout = os.Inherit, check = false)
    PathRef(os.pwd / scriptName)
  }

  def test() = T.command {
    if (os.exists(os.pwd / s"${scriptName}.test.scala")) runTest(scriptName)
    def runTest(script: String) = {
      val out = os
        .proc("scala-cli", "test", s"${script}.test.scala")
        .call(stdout = os.Inherit)
    }
  }
}

// Root level tasks used to run task on all defined scripts
def allNative(implicit ev: eval.Evaluator) = T.command(runOnAll("native"))
def allTest(implicit ev: eval.Evaluator)   = T.command(runOnAll("test"))
def allRun(implicit ev: eval.Evaluator)    = T.command(runOnAll("run"))
def runOnAll(cmd: String)(implicit ev: eval.Evaluator) = T.task {
  mill.main.MainModule.evaluateTasks(
    ev,
    Seq("__." + cmd),
    mill.define.SelectMode.Separated,
  )(identity)
}
def runTasks(t: Seq[String])(implicit ev: eval.Evaluator) = T.task {
  mill.main.MainModule.evaluateTasks(
    ev,
    t.flatMap(x => x +: Seq("+")).flatMap(x => x.split(" ")).dropRight(1),
    mill.define.SelectMode.Separated,
  )(identity)
}
