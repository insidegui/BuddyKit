import Foundation
import AppleArchive
import System
import CryptoKit

public enum URLArchiveError: LocalizedError {
    case remoteURLNotSupported
    case fileNotFound(String)
    case algorithmNotSpecified
    case readStreamInit
    case writeStreamInit
    case encodeStreamInit
    case extractStreamInit
    case keySetInit
    case sourceDirectoryComponentNotFound
    case outputDirectoryCreationFailed(Error)
    case encryptionKey(Error)
    case compressionStreamInit
    case encryptionStreamInit
    case encryptionContextInit
    case process(Error)

    public var failureReason: String? {
        switch self {
        case .remoteURLNotSupported: "Only file URLs are supported."
        case .fileNotFound(let string): "File not found: \(string.quoted)."
        case .algorithmNotSpecified: "Algorithm must be specified when extracting an encrypted file."
        case .readStreamInit: "Error initializing read stream."
        case .writeStreamInit: "Error initializing write stream."
        case .encodeStreamInit: "Error initializing encode stream."
        case .extractStreamInit: "Error initializing extract stream."
        case .keySetInit: "Error initializing key set."
        case .sourceDirectoryComponentNotFound: "Couldn't find source directory component"
        case .outputDirectoryCreationFailed(let error): "Output directory creation failed with error: \(error)"
        case .encryptionKey(let error): "Crypto configuration failed with error: \(error)"
        case .compressionStreamInit: "Error initializing compression stream."
        case .encryptionStreamInit: "Error initializing encryption stream."
        case .encryptionContextInit: "Error initializing encryption context."
        case .process(let error): "Processing failed with error: \(error)"
        }
    }
}

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

}

extension URL {

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
            destinationStream = try Self.archiveEncryptionStream(
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
            destinationStream = try Self.archiveDecryptionStream(
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
            destinationStream = try Self.archiveEncryptionStream(
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
            destinationStream = try Self.archiveDecryptionStream(
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

// MARK: - Encryption Helpers

private extension URL {
    static func archiveEncryptionStream(writingTo writeStream: ArchiveByteStream, encryptionKey: SymmetricKey, algorithm: ArchiveCompression) throws(URLArchiveError) -> ArchiveByteStream {
        let context = ArchiveEncryptionContext(
            profile: .hkdf_sha256_aesctr_hmac__symmetric__none,
            compressionAlgorithm: algorithm
        )

        do {
            try context.setSymmetricKey(encryptionKey)
        } catch {
            throw URLArchiveError.encryptionKey(error)
        }

        let stream = try ArchiveByteStream.encryptionStream(
            writingTo: writeStream,
            encryptionContext: context
        )
        .require(URLArchiveError.encryptionStreamInit)

        return stream
    }

    static func archiveDecryptionStream(readingFrom readStream: ArchiveByteStream, encryptionKey: SymmetricKey) throws(URLArchiveError) -> ArchiveByteStream {
        let context = try ArchiveEncryptionContext(
            from: readStream
        )
        .require(URLArchiveError.encryptionStreamInit)

        do {
            try context.setSymmetricKey(encryptionKey)
        } catch {
            throw URLArchiveError.encryptionKey(error)
        }

        let stream = try ArchiveByteStream.decryptionStream(
            readingFrom: readStream,
            encryptionContext: context
        )
        .require(URLArchiveError.encryptionStreamInit)

        return stream
    }
}
