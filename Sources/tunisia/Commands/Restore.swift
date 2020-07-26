//
//  File.swift
//  
//
//  Created by Jorge Revuelta on 26/07/2020.
//

import Foundation
import TunisiaKit
import CarthageKit
import ArgumentParser

struct Restore: ParsableCommand {
    
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
        let carthagePath = workingDirectory + "/Carthage/Build"
        for (dependency, pinnedVersion) in cartfile.dependencies {
            let finalPathWithVersion = try FileUtils.cachePath(for: dependency, pinnedVersion, cacheBaseDirectory: cacheDirectory)
            if !dependenciesToRestore.contains(dependency.name) && !dependenciesToRestore.isEmpty {
                print("Skipping the restore of \(dependency.name) by configuration.".green)
                continue
            }
            guard FileUtils.exists(path: finalPathWithVersion.path) else {
                print("Cache not found for \(dependency.name) at \(pinnedVersion.commitish)".yellow)
                continue
            }
            print("Restoring \(dependency.name) at \(pinnedVersion.commitish)".blue)
            let destinationPath = carthagePath + "/" + dependency.name
            
            try? FileUtils.createDir(destinationPath)
            let contents = try FileManager.default.contentsOfDirectory(at: finalPathWithVersion, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for directory in contents {
                try FileUtils.copy(path: directory.path, to: destinationPath + "/" + directory.pathComponents.last!)
            }
            print("Restored \(dependency.name) at \(pinnedVersion.commitish)".green)
        }
    }
}
