import Foundation
import AppleArchive
import CryptoKit

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension ArchiveByteStream {
    static func encryptionStream(writingTo writeStream: ArchiveByteStream, encryptionKey: SymmetricKey, algorithm: ArchiveCompression) throws(URLArchiveError) -> ArchiveByteStream {
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

    static func decryptionStream(readingFrom readStream: ArchiveByteStream, encryptionKey: SymmetricKey) throws(URLArchiveError) -> ArchiveByteStream {
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
