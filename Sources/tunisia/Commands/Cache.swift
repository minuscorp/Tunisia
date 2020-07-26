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

import ArgumentParser
import CarthageKit
import Foundation
import Rainbow
import Result
import SwiftShell
import TunisiaKit
import XCDBLD

struct Cache: ParsableCommand {
    @Flag
    var force: Bool = false

    @Option(name: .shortAndLong, help: "The destination directory of the cache")
    var destinationDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.absoluteString

    @Option(name: .shortAndLong, help: "The working directory from where to find the Cartfile")
    var workingDirectory: String = FileManager.default.currentDirectoryPath

    @Argument(help: "The carthage verb to apply to Tunisia")
    var carthageVerb: String

    @Argument(parsing: .unconditionalRemaining, help: "The carthage arguments to apply to Tunisia.")
    var carthageCommand: [String] = []

    func run() throws {
        FileUtils.cd(workingDirectory)
        let directoryURL = URL(fileURLWithPath: workingDirectory, isDirectory: true)
        let project = Project(directoryURL: directoryURL)
        let cartfile = try ResolvedCartfile.from(string: String(contentsOf: project.resolvedCartfileURL)).get()
        let (arguments, dependencies) = cleanCarthageCommand(carthageCommand)
        let (carthageDir, mainContext) = try CommandUtils.carthageDir()
        let carthagePath = workingDirectory + "/Carthage/Build"
        if carthageVerb != "bootstrap", carthageVerb != "build" {
            throw Error.default("Invalid carthage command found: \(carthageVerb) expected ['bootstrap', 'build']")
        }
        for (dependency, pinnedVersion) in cartfile.dependencies {
            let finalPathWithVersion = try FileUtils.cachePath(for: dependency, pinnedVersion, cacheBaseDirectory: destinationDirectory)
            try? FileUtils.remove(path: carthagePath)
            if !dependencies.contains(dependency.name) && !dependencies.isEmpty {
                print("Skipping \(dependency.description) by configuration.".green)
                continue
            }
            if FileUtils.exists(path: finalPathWithVersion.path) && !force {
                print("Skipping \(dependency.description), previous cache found.".green)
            }
            print("Preparing to cache \(dependency.description) at \(pinnedVersion.commitish)".blue)
            let commandString = "\(carthageVerb) \(arguments.split(separator: " ")) \(dependency.name)"
            print("Executing: carthage \(commandString)")
            mainContext.env["PWD"] = workingDirectory
            let command = mainContext.runAsyncAndPrint(carthageDir, carthageVerb, arguments, dependency.name)
            try command.finish()
            print("Finished running carthage task".green)
            print("Caching the compiled dependency".blue)
            try FileUtils.createDir(finalPathWithVersion.deletingLastPathComponent())
            try? FileUtils.remove(path: finalPathWithVersion.path)
            do {
                try FileUtils.copy(path: carthagePath, to: finalPathWithVersion.path)
            } catch {
                try FileUtils.createDir(finalPathWithVersion.path)
            }
        }
    }
    
    private func cachePath(for dependency: (Dependency, PinnedVersion)) throws -> URL {
        let xcodeVersion = try CommandUtils.xcodeVersion()
        let swiftVersion = try CommandUtils.swiftVersion()
        let path = Tunisia.name.lowercased() + "/" + "X\(xcodeVersion)_S\(swiftVersion)" + "/" + dependency.0.name
        let dataPath = URL(fileURLWithPath: destinationDirectory, isDirectory: true).appendingPathComponent(path)
        return dataPath.appendingPathComponent("\(dependency.1.commitish)")
    }

    private func cleanCarthageCommand(_ command: [String]) -> (arguments: [String], dependencies: [String]) {
        var arguments = [String]()
        var dependencies = [String]()
        if let buildPlatforms = BuildPlatform.from(string: command.joined(separator: " ")) {
            let platform: [String] = ["--platform"] + buildPlatforms.description.split(separator: " ").map { String($0) }
            arguments += platform
        }
        arguments += command.filter { $0.starts(with: "--") }.filter { !$0.contains("platform") }
        dependencies += Set(command).subtracting(arguments)
        return (arguments, dependencies)
    }
}
