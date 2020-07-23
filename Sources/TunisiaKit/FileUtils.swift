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
        if Self.exists(path: path) {
            return try? String(contentsOfFile: path, encoding: encoding)
        }
        return nil
    }

    public static func write(path: String, content: String, encoding: String.Encoding = .utf8) -> Bool {
        ((try? content.write(toFile: path, atomically: true, encoding: encoding)) != nil) ? true : false
    }

    public static func remove(path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }

    public static func copy(path: String, to destinationPath: String) throws {
        try FileManager.default.moveItem(atPath: path, toPath: destinationPath)
    }

    @discardableResult
    public static func cd(_ path: String) -> Bool {
        FileManager.default.changeCurrentDirectoryPath(path)
    }
}
