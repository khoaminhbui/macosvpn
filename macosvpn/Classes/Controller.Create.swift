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

import Darwin
import SystemConfiguration

extension Controller {
  public enum Create {
    public static func call() throws {

      // If this process has root privileges, it will be able to write to the System Keychain.
      // If not, we cannot (unless we use a helper tool, which is not the way this application is designed)
      // It would be nice to just try to perform the authorization and see if we succeeded or not.
      // But the Security System will popup an auth dialog, which is *not* enough to write to the System Keychain.
      // So, for now, we will simply bail out unless you called this command line application with the good old `sudo`.
      guard getuid() == 0 else {
        throw ExitError(message: "Sorry, without superuser privileges I won't be able to write to the System Keychain and thus cannot create a VPN service",
                        code: .privilegesRequired)
      }

      let prefs = try Authorization.preferences()

      // Making sure other processes cannot make configuration modifications
      // by obtaining a system-wide lock over the system preferences.
      guard SCPreferencesLock(prefs, true) else {
        throw ExitError(message: "Could not obtain global System Preferences Lock.",
                        code: .couldNotLockSystemPreferences,
                        systemStatus: true)
      }
      Log.info("Gained superhuman rights.");

      // Later, when we're done, other processes may modify the system configuration again
      defer { SCPreferencesUnlock(prefs) }

      let serviceConfigs = Arguments.serviceConfigs
      if (serviceConfigs.count == 0) {
        throw ExitError(message: "You did not specify any interfaces for me to create. Try --help for more information.",
                        code: .mustSpecifySomeServiceToCreate)
      }

      // Each desired interface configuration will be processed in turn.
      // The configuration comes from the command line arguments and is passed on to the create method.
      for config: ServiceConfig in serviceConfigs {
        try ServiceConfig.Creator.create(config, usingPreferencesRef: prefs)
        // This particular interface could not be created. Let's stop processing the others.
        //if (exitCode != 0) { break; } // VPNExitCode.Success
      }

    }
  }
}
