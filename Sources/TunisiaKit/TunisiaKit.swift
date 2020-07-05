import Foundation
import Regex
import SwiftShell
import enum CarthageKit.CarthageError

enum FileUtils {
    static func createDir(_ dataPath: URL) throws{
        try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
    }

    static func createDir(_ dataPath: String) throws {
        try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
    }

    static func exists (path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    static func directoryConstainsFile(path: String) throws -> Bool {
        let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            .filter { $0 != ".DS_Store" && $0 != "" }
        return !contents.isEmpty
    }

    static func read(path: String, encoding: String.Encoding = .utf8) -> String? {
        if FileUtils.exists(path: path) {
            return try? String(contentsOfFile: path, encoding: encoding)
        }
        return nil
    }

    static func write(path: String, content: String, encoding: String.Encoding = .utf8) -> Bool {
        ((try? content.write(toFile: path, atomically: true, encoding: encoding)) != nil) ? true : false
    }

    static func remove(path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }

    static func copy(path: String, to destinationPath: String) throws {
        try FileManager.default.moveItem(atPath: path, toPath: destinationPath)
    }
}

enum CommandUtils {
    
    private static let regex = Regex("version ([0-9.]+)")
    
    static func swiftVersion() throws -> String {
        let commandOutput = run("xcrun", "swift", "-version").stdout
        if
            let captures = regex.firstMatch(in: commandOutput),
            let lastCapture = captures.captures.last,
            let version = lastCapture
        {
            return version
        } else {
            throw Error.default("Swift version not found in command output")
        }
    }
    
    static func xcodeVersion() throws -> String {
        let commandOutput = run("llvm-gcc", "-v").stdout
        if
            let captures = regex.firstMatch(in: commandOutput),
            let lastCapture = captures.captures.last,
            let version = lastCapture
        {
            return version
        } else {
            throw Error.default("LLVM-GCC version not found in command output")
        }
    }
}

enum Error: Swift.Error {
    case `default`(String)
    case carthage(CarthageError)

    var localizedDescription: String {
        switch self {
        case .default(let description):
            return description
        case .carthage(let error):
            return error.description
        }
    }
}
