import Foundation

public enum ArchiveError: LocalizedError {
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
