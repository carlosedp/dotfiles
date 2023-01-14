#!/usr/bin/env -S scala-cli shebang --scala 3
// Install [scala-cli](https://scala-cli.virtuslab.org/) to use
//> using scala "3.nightly"
//> using lib "com.lihaoyi::mainargs:0.3.0"
//> using option "-Wunused:all"

import mainargs.{main, arg, ParserForMethods, Flag, Leftover}
import collection.mutable.Map

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
    @arg(short = 'f', doc = "String to print repeatedly") foo:                                        String = "Hello",
    @arg(short = 'n', doc = "How many times to print string") myNum:                                  Int = 1,
    @arg(short = 'c', doc = "Example flag, can be passed without any value to become true") callmain: Flag,
    @arg(short = 'e', doc = "Extra arguments") extraArgs:                                             Leftover[String],
  ) =
    // Use arguments
    println(foo * myNum + " ")
    println(extraArgs)
    // Call script main function
    if !callmain.value then TemplateScript.main
  def main(args: Array[String]): Unit = ParserForMethods(this).runOrExit(args.toIndexedSeq)
}

Main.main(args)
