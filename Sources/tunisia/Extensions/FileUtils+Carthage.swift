//
//  File.swift
//  
//
//  Created by Jorge Revuelta on 26/07/2020.
//

import Foundation
import CarthageKit
import TunisiaKit

extension FileUtils {
    static func cachePath(for dependency: Dependency, _ version: PinnedVersion, cacheBaseDirectory: String) throws -> URL {
        let xcodeVersion = try CommandUtils.xcodeVersion()
        let swiftVersion = try CommandUtils.swiftVersion()
        let path = Tunisia.name.lowercased() + "/" + "X\(xcodeVersion)_S\(swiftVersion)" + "/" + dependency.name
        let dataPath = URL(fileURLWithPath: cacheBaseDirectory, isDirectory: true).appendingPathComponent(path)
        return dataPath.appendingPathComponent("\(version.commitish)")
    }
}
