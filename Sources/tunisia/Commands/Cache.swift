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

import Commandant
import Curry
import Foundation
import Result
import XCDBLD
import TunisiaKit

public struct CacheCommand: CommandProtocol {
    
    public struct CacheOptions: OptionsProtocol {
        public let force: Bool
        public let verbose: Bool
        public let buildOptions: BuildOptions
        public let dependenciesToBuild: [String]?
        
        public static func evaluate(_ m: CommandMode) -> Result<CacheOptions, CommandantError<CarthageError>> {
            return curry(CacheOptions.init)
                <*> m <| Option(key: "force", defaultValue: false, usage: "To force the cache creation, invalidating potential previous values")
                <*> m <| Option(key: "verbose", defaultValue: false, usage: "Verbose output")
                <*> BuildOptions.evaluate(m)
                <*> (m <| Argument(defaultValue: [], usage: "the dependency names to build", usageParameter: "dependency names")).map { $0.isEmpty ? nil : $0 }
                
        }
        
    }
    
    public let verb = "cache"
    public let function = "Build the project's dependencies and caches them"
    
    public func run(_ options: CacheOptions) -> Result<(), CarthageError> {
        let directoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let project = Project(directoryURL: directoryURL)
        let buildProducer = project.loadResolvedCartfile()
        return .success(())
    }
    
}
