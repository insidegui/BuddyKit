/**
 Copyright (c) 2014, Kyle Fuller
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// PathKit - Effortless path operations

import Darwin

let system_glob = Darwin.glob

import Foundation

/// Represents a filesystem path.
public struct FilePath: Sendable {
    /// The character used by the OS to separate two path elements
    public static let separator = "/"

    /// The underlying string representation
    internal let path: String

    nonisolated(unsafe) internal static let fileManager = FileManager.default

    internal let fileSystemInfo: FileSystemInfo

    // MARK: Init

    public init() {
        self.init("")
    }

    /// Create a Path from a given String
    public init(_ path: String) {
        self.init(path, fileSystemInfo: DefaultFileSystemInfo())
    }

    internal init(_ path: String, fileSystemInfo: FileSystemInfo) {
        self.path = path
        self.fileSystemInfo = fileSystemInfo
    }

    internal init(fileSystemInfo: FileSystemInfo) {
        self.init("", fileSystemInfo: fileSystemInfo)
    }

    /// Create a Path by joining multiple path components together
    public init<S : Collection>(components: S) where S.Iterator.Element == String {
        let path: String
        if components.isEmpty {
            path = "."
        } else if components.first == FilePath.separator && components.count > 1 {
            let p = components.joined(separator: FilePath.separator)
            path = String(p[p.index(after: p.startIndex)...])
        } else {
            path = components.joined(separator: FilePath.separator)
        }
        self.init(path)
    }
}


// MARK: StringLiteralConvertible

extension FilePath : ExpressibleByStringLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType

    public init(extendedGraphemeClusterLiteral path: StringLiteralType) {
        self.init(stringLiteral: path)
    }

    public init(unicodeScalarLiteral path: StringLiteralType) {
        self.init(stringLiteral: path)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}


// MARK: CustomStringConvertible

extension FilePath : CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { path }
    public var debugDescription: String { description }
}


// MARK: Conversion

extension FilePath {
    public var string: String {
        return self.path
    }

    public var url: URL {
        return URL(fileURLWithPath: path)
    }
}


// MARK: Hashable

extension FilePath : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.path.hashValue)
    }
}


// MARK: Path Info

extension FilePath {
    /// Test whether a path is absolute.
    ///
    /// - Returns: `true` iff the path begins with a slash
    ///
    public var isAbsolute: Bool {
        return path.hasPrefix(FilePath.separator)
    }

    /// Test whether a path is relative.
    ///
    /// - Returns: `true` iff a path is relative (not absolute)
    ///
    public var isRelative: Bool {
        return !isAbsolute
    }

    /// Concatenates relative paths to the current directory and derives the normalized path
    ///
    /// - Returns: the absolute path in the actual filesystem
    ///
    public func absolute() -> FilePath {
        if isAbsolute {
            return normalize()
        }

        let expandedPath = FilePath(NSString(string: self.path).expandingTildeInPath)
        if expandedPath.isAbsolute {
            return expandedPath.normalize()
        }

        return (FilePath.current + self).normalize()
    }

    /// Normalizes the path, this cleans up redundant ".." and ".", double slashes
    /// and resolves "~".
    ///
    /// - Returns: a new path made by removing extraneous path components from the underlying String
    ///   representation.
    ///
    public func normalize() -> FilePath {
        return FilePath(NSString(string: self.path).standardizingPath)
    }

    /// De-normalizes the path, by replacing the current user home directory with "~".
    ///
    /// - Returns: a new path made by removing extraneous path components from the underlying String
    ///   representation.
    ///
    public func abbreviate() -> FilePath {
        let rangeOptions: String.CompareOptions = fileSystemInfo.isFSCaseSensitiveAt(path: self) ?
        [.anchored] : [.anchored, .caseInsensitive]
        let home = FilePath.home.string
        guard let homeRange = self.path.range(of: home, options: rangeOptions) else { return self }
        let withoutHome = FilePath(self.path.replacingCharacters(in: homeRange, with: ""))

        if withoutHome.path.isEmpty || withoutHome.path == FilePath.separator {
            return FilePath("~")
        } else if withoutHome.isAbsolute {
            return FilePath("~" + withoutHome.path)
        } else {
            return FilePath("~") + withoutHome.path
        }
    }

    /// Returns the path of the item pointed to by a symbolic link.
    ///
    /// - Returns: the path of directory or file to which the symbolic link refers
    ///
    public func symlinkDestination() throws -> FilePath {
        let symlinkDestination = try FilePath.fileManager.destinationOfSymbolicLink(atPath: path)
        let symlinkPath = FilePath(symlinkDestination)
        if symlinkPath.isRelative {
            return self + ".." + symlinkPath
        } else {
            return symlinkPath
        }
    }
}

internal protocol FileSystemInfo: Sendable {
    func isFSCaseSensitiveAt(path: FilePath) -> Bool
}

internal struct DefaultFileSystemInfo: FileSystemInfo {
    func isFSCaseSensitiveAt(path: FilePath) -> Bool {
        var isCaseSensitive = false
        // Calling resourceValues will fail if the path does not exist on the filesystem, which
        // makes sense, but means we can only guarantee the return value is correct if the
        // path actually exists.
        if let resourceValues = try? path.url.resourceValues(forKeys: [.volumeSupportsCaseSensitiveNamesKey]) {
            isCaseSensitive = resourceValues.volumeSupportsCaseSensitiveNames ?? isCaseSensitive
        }
        return isCaseSensitive
    }
}

// MARK: Path Components

extension FilePath {
    /// The last path component
    ///
    /// - Returns: the last path component
    ///
    public var lastComponent: String {
        return NSString(string: path).lastPathComponent
    }

    /// The last path component without file extension
    ///
    /// - Returns: the last path component without file extension
    ///
    public var lastComponentWithoutExtension: String { NSString(string: lastComponent).deletingPathExtension }

    /// Splits the string representation on the directory separator.
    /// Absolute paths remain the leading slash as first component.
    ///
    /// - Returns: all path components
    ///
    public var components: [String] { NSString(string: path).pathComponents }

    /// The file extension behind the last dot of the last component.
    ///
    /// - Returns: the file extension
    ///
    public var `extension`: String? {
        let pathExtension = NSString(string: path).pathExtension
        if  pathExtension.isEmpty {
            return nil
        }

        return pathExtension
    }
}


// MARK: File Info

extension FilePath {
    /// Test whether a file or directory exists at a specified path
    ///
    /// - Returns: `false` iff the path doesn't exist on disk or its existence could not be
    ///   determined
    ///
    public var exists: Bool {
        return FilePath.fileManager.fileExists(atPath: self.path)
    }

    /// Test whether a path is a directory.
    ///
    /// - Returns: `true` if the path is a directory or a symbolic link that points to a directory;
    ///   `false` if the path is not a directory or the path doesn't exist on disk or its existence
    ///   could not be determined
    ///
    public var isDirectory: Bool {
        var directory = ObjCBool(false)
        guard FilePath.fileManager.fileExists(atPath: normalize().path, isDirectory: &directory) else {
            return false
        }
        return directory.boolValue
    }

    /// Test whether a path is a regular file.
    ///
    /// - Returns: `true` if the path is neither a directory nor a symbolic link that points to a
    ///   directory; `false` if the path is a directory or a symbolic link that points to a
    ///   directory or the path doesn't exist on disk or its existence
    ///   could not be determined
    ///
    public var isFile: Bool {
        var directory = ObjCBool(false)
        guard FilePath.fileManager.fileExists(atPath: normalize().path, isDirectory: &directory) else {
            return false
        }
        return !directory.boolValue
    }

    /// Test whether a path is a symbolic link.
    ///
    /// - Returns: `true` if the path is a symbolic link; `false` if the path doesn't exist on disk
    ///   or its existence could not be determined
    ///
    public var isSymlink: Bool {
        do {
            let _ = try FilePath.fileManager.destinationOfSymbolicLink(atPath: path)
            return true
        } catch {
            return false
        }
    }

    /// Test whether a path is readable
    ///
    /// - Returns: `true` if the current process has read privileges for the file at path;
    ///   otherwise `false` if the process does not have read privileges or the existence of the
    ///   file could not be determined.
    ///
    public var isReadable: Bool {
        return FilePath.fileManager.isReadableFile(atPath: self.path)
    }

    /// Test whether a path is writeable
    ///
    /// - Returns: `true` if the current process has write privileges for the file at path;
    ///   otherwise `false` if the process does not have write privileges or the existence of the
    ///   file could not be determined.
    ///
    public var isWritable: Bool {
        return FilePath.fileManager.isWritableFile(atPath: self.path)
    }

    /// Test whether a path is executable
    ///
    /// - Returns: `true` if the current process has execute privileges for the file at path;
    ///   otherwise `false` if the process does not have execute privileges or the existence of the
    ///   file could not be determined.
    ///
    public var isExecutable: Bool {
        return FilePath.fileManager.isExecutableFile(atPath: self.path)
    }

    /// Test whether a path is deletable
    ///
    /// - Returns: `true` if the current process has delete privileges for the file at path;
    ///   otherwise `false` if the process does not have delete privileges or the existence of the
    ///   file could not be determined.
    ///
    public var isDeletable: Bool {
        return FilePath.fileManager.isDeletableFile(atPath: self.path)
    }
}


// MARK: File Manipulation

extension FilePath {
    /// Create the directory.
    ///
    /// - Note: This method fails if any of the intermediate parent directories does not exist.
    ///   This method also fails if any of the intermediate path elements corresponds to a file and
    ///   not a directory.
    ///
    public func mkdir() throws -> () {
        try FilePath.fileManager.createDirectory(atPath: self.path, withIntermediateDirectories: false, attributes: nil)
    }

    /// Create the directory and any intermediate parent directories that do not exist.
    ///
    /// - Note: This method fails if any of the intermediate path elements corresponds to a file and
    ///   not a directory.
    ///
    public func mkpath() throws -> () {
        try FilePath.fileManager.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
    }

    /// Delete the file or directory.
    ///
    /// - Note: If the path specifies a directory, the contents of that directory are recursively
    ///   removed.
    ///
    public func delete() throws -> () {
        try FilePath.fileManager.removeItem(atPath: self.path)
    }

    /// Move the file or directory to a new location synchronously.
    ///
    /// - Parameter destination: The new path. This path must include the name of the file or
    ///   directory in its new location.
    ///
    public func move(_ destination: FilePath) throws -> () {
        try FilePath.fileManager.moveItem(atPath: self.path, toPath: destination.path)
    }

    /// Copy the file or directory to a new location synchronously.
    ///
    /// - Parameter destination: The new path. This path must include the name of the file or
    ///   directory in its new location.
    ///
    public func copy(_ destination: FilePath) throws -> () {
        try FilePath.fileManager.copyItem(atPath: self.path, toPath: destination.path)
    }

    /// Creates a hard link at a new destination.
    ///
    /// - Parameter destination: The location where the link will be created.
    ///
    public func link(_ destination: FilePath) throws -> () {
        try FilePath.fileManager.linkItem(atPath: self.path, toPath: destination.path)
    }

    /// Creates a symbolic link at a new destination.
    ///
    /// - Parameter destintation: The location where the link will be created.
    ///
    public func symlink(_ destination: FilePath) throws -> () {
        try FilePath.fileManager.createSymbolicLink(atPath: self.path, withDestinationPath: destination.path)
    }
}


// MARK: Current Directory

extension FilePath {
    /// The current working directory of the process
    ///
    /// - Returns: the current working directory of the process
    ///
    public static var current: FilePath {
        get {
            return self.init(FilePath.fileManager.currentDirectoryPath)
        }
        set {
            _ = FilePath.fileManager.changeCurrentDirectoryPath(newValue.description)
        }
    }

    /// Changes the current working directory of the process to the path during the execution of the
    /// given block.
    ///
    /// - Note: The original working directory is restored when the block returns or throws.
    /// - Parameter closure: A closure to be executed while the current directory is configured to
    ///   the path.
    ///
    public func chdir(closure: () throws -> ()) rethrows {
        let previous = FilePath.current
        FilePath.current = self
        defer { FilePath.current = previous }
        try closure()
    }
}


// MARK: Temporary

extension FilePath {
    /// - Returns: the path to either the user’s or application’s home directory,
    ///   depending on the platform.
    ///
    public static var home: FilePath {
        return FilePath(NSHomeDirectory())
    }

    /// - Returns: the path of the temporary directory for the current user.
    ///
    public static var temporary: FilePath {
        return FilePath(NSTemporaryDirectory())
    }

    /// - Returns: the path of a temporary directory unique for the process.
    /// - Note: Based on `NSProcessInfo.globallyUniqueString`.
    ///
    public static func processUniqueTemporary() throws -> FilePath {
        let path = temporary + ProcessInfo.processInfo.globallyUniqueString
        if !path.exists {
            try path.mkdir()
        }
        return path
    }

    /// - Returns: the path of a temporary directory unique for each call.
    /// - Note: Based on `NSUUID`.
    ///
    public static func uniqueTemporary() throws -> FilePath {
        let path = try processUniqueTemporary() + UUID().uuidString
        try path.mkdir()
        return path
    }
}


// MARK: Contents

extension FilePath {
    /// Reads the file.
    ///
    /// - Returns: the contents of the file at the specified path.
    ///
    public func read() throws -> Data {
        return try Data(contentsOf: self.url, options: NSData.ReadingOptions(rawValue: 0))
    }

    /// Reads the file contents and encoded its bytes to string applying the given encoding.
    ///
    /// - Parameter encoding: the encoding which should be used to decode the data.
    ///   (by default: `NSUTF8StringEncoding`)
    ///
    /// - Returns: the contents of the file at the specified path as string.
    ///
    public func read(_ encoding: String.Encoding = String.Encoding.utf8) throws -> String {
        return try NSString(contentsOfFile: path, encoding: encoding.rawValue).substring(from: 0) as String
    }

    /// Write a file.
    ///
    /// - Note: Works atomically: the data is written to a backup file, and then — assuming no
    ///   errors occur — the backup file is renamed to the name specified by path.
    ///
    /// - Parameter data: the contents to write to file.
    ///
    public func write(_ data: Data) throws {
        try data.write(to: normalize().url, options: .atomic)
    }

    /// Reads the file.
    ///
    /// - Note: Works atomically: the data is written to a backup file, and then — assuming no
    ///   errors occur — the backup file is renamed to the name specified by path.
    ///
    /// - Parameter string: the string to write to file.
    ///
    /// - Parameter encoding: the encoding which should be used to represent the string as bytes.
    ///   (by default: `NSUTF8StringEncoding`)
    ///
    /// - Returns: the contents of the file at the specified path as string.
    ///
    public func write(_ string: String, encoding: String.Encoding = String.Encoding.utf8) throws {
        try string.write(toFile: normalize().path, atomically: true, encoding: encoding)
    }
}


// MARK: Traversing

extension FilePath {
    /// Get the parent directory
    ///
    /// - Returns: the normalized path of the parent directory
    ///
    public func parent() -> FilePath {
        return self + ".."
    }

    /// Performs a shallow enumeration in a directory
    ///
    /// - Returns: paths to all files, directories and symbolic links contained in the directory
    ///
    public func children() throws -> [FilePath] {
        return try FilePath.fileManager.contentsOfDirectory(atPath: path).map {
            self + FilePath($0)
        }
    }

    /// Performs a deep enumeration in a directory
    ///
    /// - Returns: paths to all files, directories and symbolic links contained in the directory or
    ///   any subdirectory.
    ///
    public func recursiveChildren() throws -> [FilePath] {
        return try FilePath.fileManager.subpathsOfDirectory(atPath: path).map {
            self + FilePath($0)
        }
    }
}


// MARK: Globbing

extension FilePath {
    public static func glob(_ pattern: String) -> [FilePath] {
        var gt = glob_t()
        guard let cPattern = strdup(pattern) else {
            fatalError("strdup returned null: Likely out of memory")
        }
        defer {
            globfree(&gt)
            free(cPattern)
        }

        let flags = GLOB_TILDE | GLOB_BRACE | GLOB_MARK
        if system_glob(cPattern, flags, nil, &gt) == 0 {
            let matchc = gt.gl_matchc
            return (0..<Int(matchc)).compactMap { index in
                if let path = String(validatingCString: gt.gl_pathv[index]!) {
                    return FilePath(path)
                }

                return nil
            }
        }

        // GLOB_NOMATCH
        return []
    }

    public func glob(_ pattern: String) -> [FilePath] {
        return FilePath.glob((self + pattern).description)
    }

    public func match(_ pattern: String) -> Bool {
        guard let cPattern = strdup(pattern),
              let cPath = strdup(path) else {
            fatalError("strdup returned null: Likely out of memory")
        }
        defer {
            free(cPattern)
            free(cPath)
        }
        return fnmatch(cPattern, cPath, 0) == 0
    }
}


// MARK: SequenceType

extension FilePath : Sequence {
    public struct DirectoryEnumerationOptions : OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static let skipsSubdirectoryDescendants = DirectoryEnumerationOptions(rawValue: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants.rawValue)
        public static let skipsPackageDescendants = DirectoryEnumerationOptions(rawValue: FileManager.DirectoryEnumerationOptions.skipsPackageDescendants.rawValue)
        public static let skipsHiddenFiles = DirectoryEnumerationOptions(rawValue: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles.rawValue)
    }

    /// Represents a path sequence with specific enumeration options
    public struct PathSequence : Sequence {
        private var path: FilePath
        private var options: DirectoryEnumerationOptions
        init(path: FilePath, options: DirectoryEnumerationOptions) {
            self.path = path
            self.options = options
        }

        public func makeIterator() -> DirectoryEnumerator {
            return DirectoryEnumerator(path: path, options: options)
        }
    }

    /// Enumerates the contents of a directory, returning the paths of all files and directories
    /// contained within that directory. These paths are relative to the directory.
    public struct DirectoryEnumerator : IteratorProtocol {
        public typealias Element = FilePath

        let path: FilePath
        let directoryEnumerator: FileManager.DirectoryEnumerator?

        init(path: FilePath, options mask: DirectoryEnumerationOptions = []) {
            let options = FileManager.DirectoryEnumerationOptions(rawValue: mask.rawValue)
            self.path = path
            self.directoryEnumerator = FilePath.fileManager.enumerator(at: path.url, includingPropertiesForKeys: nil, options: options)
        }

        public func next() -> FilePath? {
            let next = directoryEnumerator?.nextObject()

            if let next = next as? URL {
                return FilePath(next.path)
            }
            return nil
        }

        /// Skip recursion into the most recently obtained subdirectory.
        public func skipDescendants() {
            directoryEnumerator?.skipDescendants()
        }
    }

    /// Perform a deep enumeration of a directory.
    ///
    /// - Returns: a directory enumerator that can be used to perform a deep enumeration of the
    ///   directory.
    ///
    public func makeIterator() -> DirectoryEnumerator {
        return DirectoryEnumerator(path: self)
    }

    /// Perform a deep enumeration of a directory.
    ///
    /// - Parameter options: FileManager directory enumerator options.
    ///
    /// - Returns: a path sequence that can be used to perform a deep enumeration of the
    ///   directory.
    ///
    public func iterateChildren(options: DirectoryEnumerationOptions = []) -> PathSequence {
        return PathSequence(path: self, options: options)
    }
}


// MARK: Equatable

extension FilePath : Equatable {}

/// Determines if two paths are identical
///
/// - Note: The comparison is string-based. Be aware that two different paths (foo.txt and
///   ./foo.txt) can refer to the same file.
///
public func ==(lhs: FilePath, rhs: FilePath) -> Bool {
    return lhs.path == rhs.path
}


// MARK: Pattern Matching

/// Implements pattern-matching for paths.
///
/// - Returns: `true` iff one of the following conditions is true:
///     - the paths are equal (based on `Path`'s `Equatable` implementation)
///     - the paths can be normalized to equal Paths.
///
public func ~=(lhs: FilePath, rhs: FilePath) -> Bool {
    return lhs == rhs
    || lhs.normalize() == rhs.normalize()
}


// MARK: Comparable

extension FilePath : Comparable {}

/// Defines a strict total order over Paths based on their underlying string representation.
public func <(lhs: FilePath, rhs: FilePath) -> Bool {
    return lhs.path < rhs.path
}


// MARK: Operators

/// Appends a Path fragment to another Path to produce a new Path
public func +(lhs: FilePath, rhs: FilePath) -> FilePath {
    return lhs.path + rhs.path
}

/// Appends a String fragment to another Path to produce a new Path
public func +(lhs: FilePath, rhs: String) -> FilePath {
    return lhs.path + rhs
}

/// Appends a String fragment to another String to produce a new Path
internal func +(lhs: String, rhs: String) -> FilePath {
    if rhs.hasPrefix(FilePath.separator) {
        // Absolute paths replace relative paths
        return FilePath(rhs)
    } else {
        var lSlice = NSString(string: lhs).pathComponents.fullSlice
        var rSlice = NSString(string: rhs).pathComponents.fullSlice

        // Get rid of trailing "/" at the left side
        if lSlice.count > 1 && lSlice.last == FilePath.separator {
            lSlice.removeLast()
        }

        // Advance after the first relevant "."
        lSlice = lSlice.filter { $0 != "." }.fullSlice
        rSlice = rSlice.filter { $0 != "." }.fullSlice

        // Eats up trailing components of the left and leading ".." of the right side
        while lSlice.last != ".." && !lSlice.isEmpty && rSlice.first == ".." {
            if lSlice.count > 1 || lSlice.first != FilePath.separator {
                // A leading "/" is never popped
                lSlice.removeLast()
            }
            if !rSlice.isEmpty {
                rSlice.removeFirst()
            }

            switch (lSlice.isEmpty, rSlice.isEmpty) {
            case (true, _):
                break
            case (_, true):
                break
            default:
                continue
            }
        }

        return FilePath(components: lSlice + rSlice)
    }
}

extension Array {
    var fullSlice: ArraySlice<Element> {
        return self[self.indices.suffix(from: 0)]
    }
}
