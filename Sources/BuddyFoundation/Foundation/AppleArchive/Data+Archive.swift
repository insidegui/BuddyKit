import Foundation
import AppleArchive
import System
import CryptoKit

public extension Data {
    func extractArchive(encryptionKey: SymmetricKey? = nil) throws(URLArchiveError) -> Data {
        do {
            return try ArchiveByteStream.withTemporaryFileStream { inputStream in
                try withUnsafeBytes { dataBuffer in
                    _ = try inputStream.write(from: dataBuffer)
                }
                defer { try? inputStream.close() }

                /// We just wrote into the buffer advancing its internal position, so gotta rewind it here.
                _ = try inputStream.seek(toOffset: 0, relativeTo: .start)

                return try ArchiveByteStream.withTemporaryFileStream { outputStream in
                    let destinationStream: ArchiveByteStream

                    if let encryptionKey {
                        destinationStream = try ArchiveByteStream.decryptionStream(
                            readingFrom: inputStream,
                            encryptionKey: encryptionKey
                        )
                    } else {
                        let decompressStream = try ArchiveByteStream.decompressionStream(
                            readingFrom: inputStream
                        )
                        .require(URLArchiveError.compressionStreamInit)

                        destinationStream = decompressStream
                    }
                    defer { try? destinationStream.close() }

                    do {
                        let count = try ArchiveByteStream.process(
                            readingFrom: destinationStream,
                            writingTo: outputStream
                        )

                        /// Rewind output stream so that we can read the entire buffer from the beginning.
                        _ = try outputStream.seek(toOffset: 0, relativeTo: .start)

                        /// Create placeholder empty data that will be filled with the contents of the output buffer.
                        var data = Data.init(repeating: 0, count: Int(count))

                        try data.withUnsafeMutableBytes { buffer in
                            let count = try outputStream.read(into: buffer)
                            print(count)
                        }

                        return data
                    } catch {
                        throw URLArchiveError.process(error)
                    }
                }
            }
        } catch let error as URLArchiveError {
            throw error
        } catch {
            throw URLArchiveError.process(error)
        }
    }
}
