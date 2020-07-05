import XCTest
import Regex
@testable import TunisiaKit

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
}
