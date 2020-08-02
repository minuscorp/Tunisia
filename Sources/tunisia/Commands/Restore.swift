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
import TunisiaKit

struct Restore: ParsableCommand {
    static var configuration = CommandConfiguration(commandName: "restore", abstract: "Restores the desired or all dependencies that might be previously cached, it will use the  Swift and the clang version to categorize the restoration to avoid incompatibilities.")

    @Option(name: .shortAndLong, help: "The directory of the cache")
    var cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.absoluteString

    @Option(name: .shortAndLong, help: "The working directory from where to find the Cartfile")
    var workingDirectory: String = FileManager.default.currentDirectoryPath

    @Argument(parsing: .remaining, help: "The carthage dependencies to restore, defaults to all.")
    var dependenciesToRestore: [String] = []

    func run() throws {
        FileUtils.cd(workingDirectory)
        let directoryURL = URL(fileURLWithPath: workingDirectory, isDirectory: true)
        let project = Project(directoryURL: directoryURL)
        let cartfile = try ResolvedCartfile.from(string: String(contentsOf: project.resolvedCartfileURL)).get()
        let carthagePath = workingDirectory + "/" + Constants.binariesFolderPath
        for (dependency, pinnedVersion) in cartfile.dependencies {
            let finalPathWithVersion = try FileUtils.cachePath(for: dependency, pinnedVersion, cacheBaseDirectory: cacheDirectory)
            if !dependenciesToRestore.contains(dependency.name), !dependenciesToRestore.isEmpty {
                print("Skipping the restore of \(dependency.name) by configuration.".green)
                continue
            }
            guard FileUtils.exists(path: finalPathWithVersion.path) else {
                print("Cache not found for \(dependency.name) at \(pinnedVersion.commitish)".yellow)
                continue
            }
            print("Restoring \(dependency.name) at \(pinnedVersion.commitish)".blue)
            let destinationPath = carthagePath

            try? FileUtils.createDir(destinationPath)
            let contents = try FileManager.default.contentsOfDirectory(at: finalPathWithVersion, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for directory in contents {
                try? FileUtils.createDir(destinationPath + "/" + directory.pathComponents.last!)
                if try FileUtils.directoryFileContents(at: directory.relativePath) {
                    let fileList = try FileManager.default.contentsOfDirectory(atPath: directory.relativePath)
                    for file in fileList where file != ".DS_Store" && file != "" {
                        let fileDirectory = destinationPath + "/" + directory.pathComponents.last! + "/" + file
                        if FileManager.default.fileExists(atPath: fileDirectory) {
                            try FileUtils.remove(path: fileDirectory)
                        }
                        try FileManager.default.copyItem(atPath: directory.appendingPathComponent(file, isDirectory: false).relativePath, toPath: fileDirectory)
                    }
                }
            }
            print("Restored \(dependency.name) at \(pinnedVersion.commitish)".green)
        }
    }
}
