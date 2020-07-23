//
// Copyright [2019] [Jorge Revuelta Herrero]
// Licensed under the Apache License, Version 2.0 (the  License);
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an  AS IS BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import Regex
import SwiftShell

public enum CommandUtils {
    private static let regex = Regex("version ([0-9.]+)")

    public static func swiftVersion() throws -> String {
        let commandOutput = run("xcrun", "swift", "-version").stdout
        if
            let captures = regex.firstMatch(in: commandOutput).flatMap({ $0.captures.last }),
            let version = captures {
            return version
        } else {
            throw Error.default("Swift version not found in command output")
        }
    }

    public static func xcodeVersion() throws -> String {
        let commandOutput = run("llvm-gcc", "-v").stderror
        if
            let captures = regex.firstMatch(in: commandOutput).flatMap({ $0.captures.last }),
            let version = captures {
            return version
        } else {
            throw Error.default("LLVM-GCC version not found in command output")
        }
    }

    public static func carthageDir() throws -> (path: String, context: MainContext) {
//        run("/bin/bash", "-c", "eval $(/usr/libexec/path_helper -s) ; echo $PATH")
        main.env["PATH"] = main.env["PATH"]! + ":/usr/bin/env" + ":/usr/local/bin"
        let commandOutput = main.run("which", "carthage")
        guard commandOutput.succeeded else {
            throw Error.default("carthage installation directory not found, please install it")
        }
        return (commandOutput.stdout, main)
    }
}
