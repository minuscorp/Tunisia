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

import Foundation

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
            self.acceptedStrings
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
