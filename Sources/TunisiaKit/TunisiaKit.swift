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

    public static func exists(path: String) -> Bool {
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
    
    @discardableResult
    public static func cd(_ path: String) -> Bool {
        FileManager.default.changeCurrentDirectoryPath(path)
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
        let commandOutput = run("llvm-gcc", "-v").stderror
        if
            let captures = regex.firstMatch(in: commandOutput).flatMap({ $0.captures.last }),
            let version = captures
        {
            return version
        } else {
            throw Error.default("LLVM-GCC version not found in command output")
        }
    }
    
    public static func carthageDir() throws -> (path: String, context: MainContext) {
        run("/bin/bash", "-c", "eval $(/usr/libexec/path_helper -s) ; echo $PATH")
        main.env["PATH"] = main.env["PATH"]! + ":/usr/bin/env" + ":/usr/local/bin"
        let commandOutput = main.run("which", "carthage")
        guard commandOutput.succeeded else {
            throw Error.default("carthage installation directory not found, please install it")
        }
        return (commandOutput.stdout, main)
    }
    
    @discardableResult
    public static func runStream(launchPath: String = "/usr/local/bin/carthage", verbose: Bool = false, args: [String]) -> (output: [String], error: [String], exitCode: Int32) {
        var output: [String] = []
        var error: [String] = []

        let task = Process()
        task.launchPath = launchPath
        task.arguments = args

        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errorPipe = Pipe()
        task.standardError = errorPipe

        let outHandle = outpipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        let errorHandle = errorPipe.fileHandleForReading
        errorHandle.waitForDataInBackgroundAndNotify()

        var outObject: NSObjectProtocol?
        outObject = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                           object: outHandle, queue: nil) { notification -> Void in
            let data = outHandle.availableData
            if !data.isEmpty {
                if let str = String(data: data, encoding: .utf8) {
                    let string = str.trimmingCharacters(in: .newlines)
                    print(string)
                    output.append(string)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(outObject!)
            }
        }

        var errorObject: NSObjectProtocol?
        errorObject = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                             object: errorHandle, queue: nil) { notification -> Void in
            let data = errorHandle.availableData
            if !data.isEmpty {
                if let str = String(data: data, encoding: .utf8) {
                    let string = str.trimmingCharacters(in: .newlines)
                    error.append(string)
                    print(string)
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(errorObject!)
            }
        }

        task.launch()
        task.waitUntilExit()
        let status = task.terminationStatus
        return (output, error, status)
        
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

/// Represents the user's chosen platform to build for.
public enum BuildPlatform: Equatable {
    /// Build for all available platforms.
    case all

    /// Build only for iOS.
    case iOS

    /// Build only for macOS.
    case macOS

    /// Build only for watchOS.
    case watchOS

    /// Build only for tvOS.
    case tvOS

    /// Build for multiple platforms within the list.
    case multiple([BuildPlatform])
}

extension BuildPlatform: CustomStringConvertible {
    public var description: String {
        switch self {
        case .all:
            return "all"

        case .iOS:
            return "iOS"

        case .macOS:
            return "macOS"

        case .watchOS:
            return "watchOS"

        case .tvOS:
            return "tvOS"

        case let .multiple(buildPlatforms):
            return buildPlatforms.map { $0.description }.joined(separator: ", ")
        }
    }
}

extension BuildPlatform {

    private static let acceptedStrings: [String: BuildPlatform] = [
        "macOS": .macOS, "Mac": .macOS, "OSX": .macOS, "macosx": .macOS,
        "iOS": .iOS, "iphoneos": .iOS, "iphonesimulator": .iOS,
        "watchOS": .watchOS, "watchsimulator": .watchOS,
        "tvOS": .tvOS, "tvsimulator": .tvOS, "appletvos": .tvOS, "appletvsimulator": .tvOS,
        "all": .all,
    ]

    public static func from(string: String) -> BuildPlatform? {
        let tokens = string.split(separator: " ")

        let findBuildPlatform: (String) -> BuildPlatform? = { string in
            return self.acceptedStrings
                .first { key, _ in string.caseInsensitiveCompare(key) == .orderedSame }
                .map { _, platform in platform }
        }

        switch tokens.count {
        case 0:
            return nil

        case 1:
            return findBuildPlatform(String(tokens[0]))

        default:
            var buildPlatforms = [BuildPlatform]()
            for token in tokens {
                if let found = findBuildPlatform(String(token)), found != .all {
                    buildPlatforms.append(found)
                } else {
                    // Reject if an invalid value is included in the comma-
                    // separated string.
                    continue
                }
            }
            return .multiple(buildPlatforms)
        }
    }
}
