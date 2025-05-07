import Foundation
import UniformTypeIdentifiers
@_exported import BuddyPathKit

public extension FilePath {

    /// The path without its last component.
    var removingLastComponent: FilePath {
        guard !components.isEmpty else { return self }
        var mComponents = components
        mComponents.removeLast()
        return FilePath(components: mComponents)
    }

    /// The path replacing the `/Users/...` prefix with `~`.
    var abbreviatingWithTilde: FilePath { FilePath((string as NSString).abbreviatingWithTildeInPath) }

    /// Returns the path relative to the specified base path.
    ///
    /// Example: `/my/custom/path/file.txt` with basePath `/my/custom/` will return `path/file.txt`.
    func relative(to basePath: FilePath) -> FilePath {
        guard !string.isEmpty else { return self }

        if basePath.string == "/" {
            return FilePath(String(string.suffix(from: string.index(string.startIndex, offsetBy: 1))))
        }
        let newString = string
            .replacingOccurrences(of: basePath.string + "/", with: "")
            .replacingOccurrences(of: basePath.string, with: "")
        return FilePath(newString)
    }

    /// Returns the path with the suffix appended before the file extension.
    ///
    /// - Parameter suffix: The suffix to be appended to the file name, before the extension.
    /// - Returns: The path with the last component having the new suffix appended before the extension.
    ///
    /// Example: appending suffix `_new` to `/path/to/myfile.txt` returns `/path/to/myfile_new.txt`.
    func appendingSuffix(_ suffix: String) -> FilePath {
        if let pathExtension = self.extension {
            removingLastComponent + "\(lastComponentWithoutExtension)\(suffix).\(pathExtension)"
        } else {
            self + suffix
        }
    }

    /// Creates directories for each component in the file path.
    /// - Parameter subpath: The directory path to create.
    /// - Returns: The path with the newly-created subpath appended to it.
    ///
    /// This performs the same operation as if you ran `mkdir -p <subpath>` within the current path.
    func creatingSubpath(_ subpath: FilePath) throws -> FilePath {
        let fullPath = self + subpath
        if !fullPath.isDirectory {
            try fullPath.mkpath()
        }
        return fullPath
    }
    
    /// Appends a file extension to the file path.
    /// - Parameter pathExtension: The extension to append (without a leading `.`). Example: `txt`.
    /// - Returns: The path with the extension appended to its last component.
    func appendingExtension(_ pathExtension: String) -> Self {
        removingLastComponent + "\(lastComponent).\(pathExtension)"
    }
    
    /// Appends a file extension from a unified type identifier to the file path.
    /// - Parameter type: The uniform type identifier.
    /// - Returns: The path with the extension appended to its last component.
    ///
    /// If `type` is `nil`, the same path is returned.
    func appendingExtension(for type: UTType?) -> Self {
        type?.preferredFilenameExtension.flatMap { appendingExtension($0) } ?? self
    }
}


