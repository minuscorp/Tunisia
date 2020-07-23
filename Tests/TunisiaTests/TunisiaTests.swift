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

import Regex
@testable import TunisiaKit
import XCTest

final class TunisiaTests: XCTestCase {
    func testSwiftVersionRegex() {
        let commandOutput = """
        Apple Swift version 5.2.2 (swiftlang-1103.0.32.6 clang-1103.0.32.51)
        Target: x86_64-apple-darwin19.4.0
        """
        let regularExpression = Regex("version ([0-9.]+)")
        if let captures = regularExpression.firstMatch(in: commandOutput) {
            XCTAssertEqual(captures.captures.last, "5.2.2")
        } else {
            XCTFail()
        }
    }

    func testXcodeVersion() {
        let commandOutput = """
        Apple clang version 11.0.3 (clang-1103.0.32.59)
        Target: x86_64-apple-darwin19.4.0
        Thread model: posix
        InstalledDir: /Applications/Xcode-11.4.1.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
        """
        let regularExpression = Regex("version ([0-9.]+)")
        if let captures = regularExpression.firstMatch(in: commandOutput) {
            XCTAssertEqual(captures.captures.last, "11.0.3")
        } else {
            XCTFail()
        }
    }

    func testDestinationDirectory() {
        let destinationDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.absoluteString
        let path = "tunisia" + "/" + "X1.0.0_S1.0.0" + "/" + "Tunisia"
        let dataPath = URL(fileURLWithPath: destinationDirectory, isDirectory: true).appendingPathComponent(path).appendingPathComponent("1.0.0")
        XCTAssertEqual(dataPath.path, destinationDirectory.replacingOccurrences(of: "file://", with: "") + path + "/" + "1.0.0")
    }
}
