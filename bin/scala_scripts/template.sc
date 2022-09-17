#!/usr/bin/env -S scala-cli shebang --scala 3
// Install [scala-cli](https://scala-cli.virtuslab.org/) to use
//> using scala "3"
//> using lib "com.lihaoyi::mainargs:0.2.3"

import mainargs.{main, arg, ParserForMethods, Flag}

object TemplateScript {
  def main =
    println("World")
}

// Run the script
object Main {
  @main(
    name = "Template Scala Script",
    doc = "Describe the Scala script briefly.",
  )
  def run(
    @arg(short = 'f', doc = "String to print repeatedly")
    foo: String = "Hello",
    @arg(name = "my-num", doc = "How many times to print string")
    myNum: Int = 1,
    @arg(doc = "Example flag, can be passed without any value to become true")
    callmain: Flag,
  ) =
    // Use arguments
    println(foo * myNum + " ")
    // Call script main function
    if !callmain.value then TemplateScript.main
  def main(args: Array[String]): Unit = ParserForMethods(this).runOrExit(args.toIndexedSeq)
}

Main.main(args)
