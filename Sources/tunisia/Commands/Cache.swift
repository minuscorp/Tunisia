/*
 Copyright [2019] [Jorge Revuelta Herrero]
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import Result
import XCDBLD
import TunisiaKit
import ArgumentParser
import SwiftShell
import Rainbow
import CarthageKit

struct Cache: ParsableCommand {
    
    @Flag
    var force: Bool = false
    
    @Flag
    var verbose: Bool = false
    
    @Option(name: .shortAndLong, help: "The destination directory of the cache")
    var destinationDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.absoluteString
    
    @Option(name: .shortAndLong, help: "The working directory from where to find the Cartfile")
    var workingDirectory: String = FileManager.default.currentDirectoryPath
    
    @Argument(parsing: .unconditionalRemaining, help: "The carthage arguments to apply to Tunisia.")
    var carthageCommand: [String] = []
    
    func run() throws {
        let directoryURL = URL(fileURLWithPath: workingDirectory, isDirectory: true)
        let project = Project(directoryURL: directoryURL)
        let cartfile = try ResolvedCartfile.from(string: String(contentsOf: project.resolvedCartfileURL)).get()
        let (arguments, dependencies) = cleanCarthageCommand(carthageCommand)
        for (dependency, pinnedVersion) in cartfile.dependencies {
            if dependencies.contains(dependency.description) {
                print("Skipping \(dependency.description) by configuration.".green)
                continue
            }
            print("Preparing to cache \(dependency.description) at \(pinnedVersion.commitish)".blue)
            let commandString = "carthage \(arguments) \(dependency.description)"
            print("Executing: \(commandString)")
            try runAndPrint(commandString)
            print("Finished running carthage task".green)
            print("Caching the compiled dependency".blue)
            
        }
        
    }
    
    func cleanCarthageCommand(_ command: [String]) -> (arguments: String, dependencies: String) {
        let arguments = command.filter { $0.starts(with: "--") }
        let dependencies = Set(command).subtracting(arguments)
        return (arguments.joined(separator: " "), dependencies.joined(separator: " "))
    }
    
    
//    public let verb = "cache"
//    public let function = "Build the project's dependencies and caches them"
//
//    public func run(_ options: CacheOptions) -> Result<(), CarthageError> {
//        let directoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
//        let project = Project(directoryURL: directoryURL)
//        let buildProducer = project.loadResolvedCartfile()
//        return .success(())
//    }
    
}
