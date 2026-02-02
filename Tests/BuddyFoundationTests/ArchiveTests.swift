import Foundation
import Testing
@testable import BuddyFoundation
import CryptoKit

private extension SymmetricKey {
    static let test = SymmetricKey(data: try! Data(hexString: "d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225"))
}

private extension URL {
    static func temporaryFile(extension: String? = nil) -> URL {
        let url = FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .notDirectory)
        return if let `extension` {
            url.appendingPathExtension(`extension`)
        } else {
            url
        }
    }

    static func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    }

    func delete() {
        guard FileManager.default.fileExists(atPath: absoluteURL.path(percentEncoded: false)) else { return }
        try? FileManager.default.removeItem(at: self)
    }
}

private func withTemporaryFile<T>(contents: String, perform block: (_ fileURL: URL) throws -> T) rethrows -> T {
    let fileURL = URL.temporaryFile()
    defer { fileURL.delete() }
    try! contents.write(to: fileURL, atomically: true, encoding: .utf8)

    return try block(fileURL)
}

private func withTemporaryDirectory<T>(fileContents: String..., perform block: (_ directoryURL: URL) throws -> T) rethrows -> T {
    let directoryURL = URL.temporaryDirectory()
    defer { directoryURL.delete() }

    try! FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

    for (index, fileContent) in fileContents.enumerated() {
        try! fileContent.write(to: directoryURL.appending(path: "\(index)", directoryHint: .notDirectory), atomically: true, encoding: .utf8)
    }

    return try block(directoryURL)
}

@Suite
struct ArchiveTests {
    @Test func testSymmetricKeyFromHexStringLiteral() throws {
        let decodedKey: SymmetricKey = "hex:d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225"
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testSymmetricKeyFromHexString() throws {
        let decodedKey = try SymmetricKey(appleEncryptedArchiveCompatible: "hex:d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225")
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testSymmetricKeyFromBase64String() throws {
        let decodedKey = try SymmetricKey(appleEncryptedArchiveCompatible: "base64:1gh3UwyFhJ9VcAaNAVnOkbk2lC0nDYj4NDxPzMyVciU=")
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testSymmetricKeyFromHexStringWrappedInData() throws {
        let data = Data("hex:d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225".utf8)
        let decodedKey = try SymmetricKey(appleEncryptedArchiveCompatible: data)
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testSymmetricKeyFromBase64StringWrappedInData() throws {
        let data = Data("base64:1gh3UwyFhJ9VcAaNAVnOkbk2lC0nDYj4NDxPzMyVciU=".utf8)
        let decodedKey = try SymmetricKey(appleEncryptedArchiveCompatible: data)
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testSymmetricKeyFromRawData() throws {
        let data: Data = "d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225"
        let decodedKey = try SymmetricKey(appleEncryptedArchiveCompatible: data)
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testSymmetricKeyFromRawDataFile() throws {
        let fileURL = URL.temporaryFile()
        defer { fileURL.delete() }

        let data: Data = "d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225"
        try data.write(to: fileURL)

        let decodedKey = try SymmetricKey(contentsOf: fileURL)
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testSymmetricKeyFromHexStringFile() throws {
        let fileURL = URL.temporaryFile()
        defer { fileURL.delete() }

        let data = Data("hex:d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225".utf8)
        try data.write(to: fileURL)

        let decodedKey = try SymmetricKey(contentsOf: fileURL)
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testSymmetricKeyFromBase64StringFile() throws {
        let fileURL = URL.temporaryFile()
        defer { fileURL.delete() }

        let data = Data("base64:1gh3UwyFhJ9VcAaNAVnOkbk2lC0nDYj4NDxPzMyVciU=".utf8)
        try data.write(to: fileURL)

        let decodedKey = try SymmetricKey(contentsOf: fileURL)
        #expect(decodedKey == SymmetricKey.test)
    }

    @Test func testCompressDecompressSingleFile() throws {
        try withTemporaryFile(contents: "Hello, Compression!") { fileURL in
            let compressedURL = URL.temporaryFile(extension: "aar")
            defer { compressedURL.delete() }

            try fileURL.compress(to: compressedURL)

            let compressedData = try Data(contentsOf: compressedURL)
            #expect(compressedData.count == 47)
            #expect(compressedData.hexString.uppercased() == "70627A6500000000001000000000000000000013000000000000001348656C6C6F2C20436F6D7072657373696F6E21")

            let extractedURL = URL.temporaryFile()
            defer { extractedURL.delete() }
            try compressedURL.extractFile(to: extractedURL)

            let extractedData = try Data(contentsOf: extractedURL)
            let extractedString = String(decoding: extractedData, as: UTF8.self)

            #expect(extractedString == "Hello, Compression!")
        }
    }

    @Test func testCompressDecompressDirectory() throws {
        try withTemporaryDirectory(fileContents: "File Contents 0", "File Contents 1", "File Contents 2") { directoryURL in
            let compressedURL = URL.temporaryFile(extension: "aar")
            defer { compressedURL.delete() }

            try directoryURL.compress(to: compressedURL)

            let compressedData = try Data(contentsOf: compressedURL)

            /// Can't match exact size here.
            #expect(compressedData.count >= 200)

            /// Can't match exact file structure here because file metadata is not static.
            #expect(compressedData.hexString.uppercased().contains("46696C6520436F6E74656E74732030"))

            let extractedURL = URL.temporaryDirectory()
            defer { extractedURL.delete() }

            try compressedURL.extractDirectory(to: extractedURL)

            /// A new directory with the name of the input directory will be created in the extracted directory.
            let extractedDirURL = extractedURL.appending(path: directoryURL.lastPathComponent, directoryHint: .isDirectory)
            let url0 = extractedDirURL.appending(path: "0")
            let url1 = extractedDirURL.appending(path: "1")
            let url2 = extractedDirURL.appending(path: "2")

            #expect(try String(contentsOf: url0, encoding: .utf8) == "File Contents 0")
            #expect(try String(contentsOf: url1, encoding: .utf8) == "File Contents 1")
            #expect(try String(contentsOf: url2, encoding: .utf8) == "File Contents 2")
        }
    }

    @Test func testEncryptDecryptSingleFile() throws {
        try withTemporaryFile(contents: "Hello, Encryption!") { fileURL in
            let encryptedURL = URL.temporaryFile(extension: "aea")
            defer { encryptedURL.delete() }

            try fileURL.compress(to: encryptedURL, encryptionKey: .test)
            print(encryptedURL.path(percentEncoded: false))

            let encryptedData = try Data(contentsOf: encryptedURL, options: .mappedIfSafe)

            /// Sanity check: file size (typically around 19kb for small single file).
            #expect(encryptedData.count >= 16000)

            /// Sanity check: file starts with AEA header.
            #expect(encryptedData.hexString.uppercased().hasPrefix("414541310100000000000000"))

            /// Ensure encrypted file doesn't contain input in plain text.
            #expect(!encryptedData.hexString.uppercased().contains("48656C6C6F2C20456E6372797074696F6E21"))

            let extractedURL = URL.temporaryFile()
            defer { extractedURL.delete() }
            
            try encryptedURL.extractFile(to: extractedURL, encryptionKey: .test)

            let decryptedData = try Data(contentsOf: extractedURL)
            let decryptedString = String(decoding: decryptedData, as: UTF8.self)

            #expect(decryptedString == "Hello, Encryption!")
        }
    }
}
