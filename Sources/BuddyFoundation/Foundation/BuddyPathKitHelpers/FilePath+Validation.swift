import Foundation
import BuddyPathKit

public extension FilePath {
    /// Throws if the path doesn't point to an existing file, or if it points to a directory instead of a regular file.
    /// No validation occurs if path is a TTY.
    func validateFileExists() throws {
        guard !isTTY else { return }

        try exists
            .require("File doesn't exist at \(string.quoted).")

        try (!isDirectory)
            .require("Path is not a regular file at \(string.quoted).")
    }

    /// Throws if the path doesn't point to an existing directory, or if it points to a regular file instead of a directory.
    /// No validation occurs if path is a TTY.
    func validateDirectoryExists() throws {
        guard !isTTY else { return }

        try exists
            .require("Directory doesn't exist at \(string.quoted).")

        try isDirectory
            .require("Path is not a directory at \(string.quoted).")
    }

    /// Throws if the path doesn't point to an existing file or directory.
    /// No validation occurs if path is a TTY.
    func validateExists() throws {
        guard !isTTY else { return }

        try exists
            .require("Path doesn't exist at \(string.quoted).")
    }

    /// Throws if the path points to an existing file or directory.
    /// No validation occurs if path is a TTY.
    func validateNotExists() throws {
        guard !isTTY else { return }

        try (!exists)
            .require("Path already exists at \(string.quoted).")
    }
}
