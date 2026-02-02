import Foundation
import CryptoKit

/**
 This extension adds support for different ways of representing a symmetric key that are supported by Apple Encrypted Archive and the `aea` command-line tool.
 */

@available(macOS 13.0, *)
extension SymmetricKey: @retroactive ExpressibleByStringLiteral {
    private static let hexPrefix = "hex:"
    private static let base64Prefix = "base64:"

    /// Initializes a `SymmetricKey` with a static string representing the key in one of the formats supported by the `aea` command-line tool:
    ///
    /// - `hex:...`: the prefix `hex:` followed by the key represented as a hexadecimal string
    /// - `base64:...` the prefix `base64:` followed by the key represented as a base64-encoded string.
    ///
    /// - note: To initialize a symmetric key from a dynamic string that's not known at compile time,
    /// use the throwing initializer in this extension and handle errors accordingly.
    public init(stringLiteral value: StaticString) {
        do {
            try self.init(appleEncryptedArchiveCompatible: "\(value)")
        } catch {
            preconditionFailure("Invalid SymmetricKey string: \"\(value)\".")
        }
    }

    /// Initializes a symmetric key by decoding a string representing the key in one of the formats supported by the `aea` command-line tool:
    ///
    /// - `hex:...`: the prefix `hex:` followed by the key represented as a hexadecimal string
    /// - `base64:...` the prefix `base64:` followed by the key represented as a base64-encoded string.
    ///
    /// > Tip: If you know the key string at compile time, you can take advantage of `ExpressibleByStringLiteral` conformance
    /// > to initialize a `SymmetricKey` from a string directly, example:
    /// > ```swift
    /// > let myKey: SymmetricKey = "hex:d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225"
    /// > ```
    public init(appleEncryptedArchiveCompatible string: String) throws {
        if string.hasPrefix(Self.hexPrefix) {
            try self.init(hexString: string.removingPrefix(Self.hexPrefix))
        } else if string.hasPrefix(Self.base64Prefix) {
            try self.init(base64String: string.removingPrefix(Self.base64Prefix))
        } else {
            try self.init(hexString: string)
        }
    }
    
    /// Initializes a symmetric key by decoding a string or raw data in one of the formats supported by the `aea` command-line tool.
    /// - Parameter data: The data containing either the raw key or a string representing the key in one of the supported formats.
    public init(appleEncryptedArchiveCompatible data: Data) throws {
        if let string = String(data: data, encoding: .utf8) {
            /// Data could be input from a file containing `hex:...` or `base64:...`, so if we're able
            /// to parse input as a string, try initializing from that first.
            if let key = try? Self.init(appleEncryptedArchiveCompatible: string) {
                self = key
            } else {
                self.init(data: data)
            }
        } else {
            self.init(data: data)
        }
    }
    
    /// Initializes a symmetric key by reading it from a file containing the raw key or a string representing the key in one of the formats supported by the `aea` command-line tool.
    /// - Parameter file: The file containing either the raw key or a string representing the key in one of the supported formats.
    public init(contentsOf file: URL) throws {
        try self.init(appleEncryptedArchiveCompatible: Data(contentsOf: file, options: .mappedIfSafe))
    }
    
    /// Initializes a symmetric key from a hex-encoded string representation.
    /// - Parameter hexString: A hex-encoded string representation such as `d60877530c85849f5570068d0159ce91b936942d270d88f8343c4fcccc957225`.
    public init(hexString: String) throws {
        try self.init(data: Data(hexString: hexString))
    }
    
    /// Initializes a symmetric key from a base64-encoded string representation.
    /// - Parameter base64String: A base64-encoded string representation such as `1gh3UwyFhJ9VcAaNAVnOkbk2lC0nDYj4NDxPzMyVciU=`.
    public init(base64String: String) throws {
        try self.init(data: Data(base64Encoded: base64String).require("Invalid base64 string: \(base64String.quoted)"))
    }
}
