/*
 * Copyright (C) 2014-2019 halo https://github.com/halo/macosvpn
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

public enum Controller {
  public enum Main {
    public static func call() -> Int32 {
      do {
        // Parse all CLI arguments
        try Arguments.load()

      } catch let error as ExitError {
        Log.error("")
        Log.error(error.localizedDescription)
        Log.error("")
        return error.code.rawValue

      } catch {
        Log.info("Unexpected error: \(error.localizedDescription)")
        return ExitCode.unexpectedControllerRunError.rawValue
      }

      // Adding the --version flag should never perform anything
      // except for showing the version (without any blank rows).
      if Arguments.options.command == .version {
        Help.showVersion()
        return ExitCode.showingVersion.rawValue
      }

      // In every other case, we print out an empty row for readability.
      Log.info("")
      // And one empty row after.
      defer { Log.info(" ") }

      // Adding the --help flag should simply show the help.
      // This will be padded with blank lines above and under.
      if Arguments.options.command == .help {
        Help.showHelp()
        return ExitCode.showingHelp.rawValue
      }

      do {
        try Controller.Run.call()

      } catch let error as ExitError {
        Log.error(error.localizedDescription)
        return error.code.rawValue

      } catch {
        Log.info("Unexpected error: \(error.localizedDescription)")
        return ExitCode.unexpectedControllerRunError.rawValue
      }

      // Mention that there were no errors so we can trace bugs more easily.
      Log.info("Finished without errors.")
      return ExitCode.success.rawValue
    }
  }
}
