import Foundation
import Regex
import SwiftShell
import enum CarthageKit.CarthageError

public enum FileUtils {
    public static func createDir(_ dataPath: URL) throws {
        try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
    }

    public static func createDir(_ dataPath: String) throws {
        try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil)
    }

    public static func exists (path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    public static func directoryConstainsFile(path: String) throws -> Bool {
        let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            .filter { $0 != ".DS_Store" && $0 != "" }
        return !contents.isEmpty
    }

    public static func read(path: String, encoding: String.Encoding = .utf8) -> String? {
        if FileUtils.exists(path: path) {
            return try? String(contentsOfFile: path, encoding: encoding)
        }
        return nil
    }

    public static func write(path: String, content: String, encoding: String.Encoding = .utf8) -> Bool {
        ((try? content.write(toFile: path, atomically: true, encoding: encoding)) != nil) ? true : false
    }

    public static func remove(path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }

    public static func copy(path: String, to destinationPath: String) throws {
        try FileManager.default.moveItem(atPath: path, toPath: destinationPath)
    }
}

public enum CommandUtils {
    
    private static let regex = Regex("version ([0-9.]+)")
    
    public static func swiftVersion() throws -> String {
        let commandOutput = run("xcrun", "swift", "-version").stdout
        if
            let captures = regex.firstMatch(in: commandOutput).flatMap({ $0.captures.last }),
            let version = captures
        {
            return version
        } else {
            throw Error.default("Swift version not found in command output")
        }
    }
    
    public static func xcodeVersion() throws -> String {
        let commandOutput = run("llvm-gcc", "-v").stdout
        if
            let captures = regex.firstMatch(in: commandOutput).flatMap({ $0.captures.last }),
            let version = captures
        {
            return version
        } else {
            throw Error.default("LLVM-GCC version not found in command output")
        }
    }
}

public enum Error: Swift.Error {
    case `default`(String)
    case carthage(CarthageError)

    public var localizedDescription: String {
        switch self {
        case .default(let description):
            return description
        case .carthage(let error):
            return error.description
        }
    }
}
