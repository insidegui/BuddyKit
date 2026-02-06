import Foundation
import AppleArchive
import System
import CryptoKit

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public typealias URLArchiveError = ArchiveError

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension URL {

    func compress(to outputURL: URL, using algorithm: ArchiveCompression = .lzfse, encryptionKey: SymmetricKey? = nil) throws(URLArchiveError) {
        try isFileURL.require(URLArchiveError.remoteURLNotSupported)

        let path: String = if #available(macOS 13.0, *) {
            absoluteURL.path(percentEncoded: false)
        } else {
            absoluteURL.path
        }

        var isDir = ObjCBool.init(false)
        try FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            .require(URLArchiveError.fileNotFound(path))

        if isDir.boolValue {
            try compressDirectory(to: outputURL, using: algorithm, encryptionKey: encryptionKey)
        } else {
            try compressFile(to: outputURL, using: algorithm, encryptionKey: encryptionKey)
        }
    }

    func compressFile(to outputURL: URL, using algorithm: ArchiveCompression, encryptionKey: SymmetricKey? = nil) throws(URLArchiveError) {
        let sourceFilePath = System.FilePath(self.path)

        let readFileStream = try ArchiveByteStream.fileStream(
            path: sourceFilePath,
            mode: .readOnly,
            options: [],
            permissions: FilePermissions(rawValue: 0o644)
        )
        .require(URLArchiveError.readStreamInit)
        defer { try? readFileStream.close() }

        let archiveFilePath = System.FilePath(outputURL.path)

        let writeFileStream = try ArchiveByteStream.fileStream(
            path: archiveFilePath,
            mode: .writeOnly,
            options: [.create],
            permissions: FilePermissions(rawValue: 0o644)
        )
        .require(URLArchiveError.writeStreamInit)
        defer { try? writeFileStream.close() }

        let destinationStream: ArchiveByteStream

        if let encryptionKey {
            destinationStream = try ArchiveByteStream.encryptionStream(
                writingTo: writeFileStream,
                encryptionKey: encryptionKey,
                algorithm: algorithm
            )
        } else {
            let compressStream = try ArchiveByteStream.compressionStream(
                using: algorithm,
                writingTo: writeFileStream
            )
            .require(URLArchiveError.compressionStreamInit)

            destinationStream = compressStream
        }
        defer { try? destinationStream.close() }

        do {
            _ = try ArchiveByteStream.process(
                readingFrom: readFileStream,
                writingTo: destinationStream
            )
        } catch {
            throw URLArchiveError.process(error)
        }
    }

    func extractFile(to outputURL: URL, encryptionKey: SymmetricKey? = nil) throws(URLArchiveError) {
        let archiveFilePath = System.FilePath(self.path)

        let readFileStream = try ArchiveByteStream.fileStream(
            path: archiveFilePath,
            mode: .readOnly,
            options: [],
            permissions: FilePermissions(rawValue: 0o644)
        )
        .require(URLArchiveError.readStreamInit)

        defer { try? readFileStream.close() }

        let destinationFilePath = System.FilePath(outputURL.path)

        let writeFileStream = try ArchiveByteStream.fileStream(
            path: destinationFilePath,
            mode: .writeOnly,
            options: [.create],
            permissions: FilePermissions(rawValue: 0o644)
        )
        .require(URLArchiveError.writeStreamInit)
        defer { try? writeFileStream.close() }

        let destinationStream: ArchiveByteStream

        if let encryptionKey {
            destinationStream = try ArchiveByteStream.decryptionStream(
                readingFrom: readFileStream,
                encryptionKey: encryptionKey
            )
        } else {
            let decompressStream = try ArchiveByteStream.decompressionStream(
                readingFrom: readFileStream
            )
            .require(URLArchiveError.compressionStreamInit)

            destinationStream = decompressStream
        }
        defer { try? destinationStream.close() }

        do {
            _ = try ArchiveByteStream.process(
                readingFrom: destinationStream,
                writingTo: writeFileStream
            )
        } catch {
            throw URLArchiveError.process(error)
        }
    }

    func compressDirectory(to outputURL: URL, using algorithm: ArchiveCompression, encryptionKey: SymmetricKey? = nil) throws(URLArchiveError) {
        let archiveFilePath = System.FilePath(outputURL.path)

        let writeFileStream = try ArchiveByteStream.fileStream(
            path: archiveFilePath,
            mode: .writeOnly,
            options: [.create],
            permissions: FilePermissions(rawValue: 0o644)
        )
        .require(URLArchiveError.writeStreamInit)
        defer { try? writeFileStream.close() }

        let destinationStream: ArchiveByteStream

        if let encryptionKey {
            destinationStream = try ArchiveByteStream.encryptionStream(
                writingTo: writeFileStream,
                encryptionKey: encryptionKey,
                algorithm: algorithm
            )
        } else {
            let compressStream = try ArchiveByteStream.compressionStream(
                using: algorithm,
                writingTo: writeFileStream
            )
            .require(URLArchiveError.compressionStreamInit)

            destinationStream = compressStream
        }

        defer { try? destinationStream.close() }

        let encodeStream = try ArchiveStream.encodeStream(
            writingTo: destinationStream
        )
        .require(URLArchiveError.encodeStreamInit)
        defer { try? encodeStream.close() }

        let keySet = try ArchiveHeader.FieldKeySet(
            "TYP,PAT,LNK,DEV,DAT,UID,GID,MOD,FLG,MTM,BTM,CTM"
        )
        .require(URLArchiveError.keySetInit)

        let source = System.FilePath(self.path)
        let parent = source.removingLastComponent()

        let sourceDirComponent = try source.lastComponent
            .require(URLArchiveError.sourceDirectoryComponentNotFound)

        do {
            try encodeStream.writeDirectoryContents(
                archiveFrom: parent,
                path: System.FilePath(sourceDirComponent.string),
                keySet: keySet
            )
        } catch {
            throw URLArchiveError.process(error)
        }
    }

    func extractDirectory(to outputURL: URL, encryptionKey: SymmetricKey? = nil) throws {
        let archiveFilePath = System.FilePath(self.path)

        let readFileStream = try ArchiveByteStream.fileStream(
            path: archiveFilePath,
            mode: .readOnly,
            options: [],
            permissions: FilePermissions(rawValue: 0o644)
        )
        .require(URLArchiveError.readStreamInit)
        defer { try? readFileStream.close() }

        let destinationStream: ArchiveByteStream

        if let encryptionKey {
            destinationStream = try ArchiveByteStream.decryptionStream(
                readingFrom: readFileStream,
                encryptionKey: encryptionKey
            )
        } else {
            let decompressStream = try ArchiveByteStream.decompressionStream(
                readingFrom: readFileStream
            )
            .require(URLArchiveError.compressionStreamInit)

            destinationStream = decompressStream
        }
        defer { try? destinationStream.close() }

        let decodeStream = try ArchiveStream.decodeStream(
            readingFrom: destinationStream
        )
        .require(URLArchiveError.encodeStreamInit)
        defer { try? decodeStream.close() }

        if !FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)
            } catch {
                throw URLArchiveError.outputDirectoryCreationFailed(error)
            }
        }

        let decompressDestination = System.FilePath(outputURL.path)

        let extractStream = try ArchiveStream.extractStream(
            extractingTo: decompressDestination,
            flags: [.ignoreOperationNotPermitted]
        )
        .require(URLArchiveError.extractStreamInit)

        do {
            _ = try ArchiveStream.process(readingFrom: decodeStream, writingTo: extractStream)
        } catch {
            throw URLArchiveError.process(error)
        }
    }

}
