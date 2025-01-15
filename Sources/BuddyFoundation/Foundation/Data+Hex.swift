import Foundation

// MARK: - Hex Encoding

public extension Data {

    /// Returns a hex-encoded string representing the contents of the data.
    ///
    /// The hex string is uppercased, with each byte being composed of two characters.
    ///
    /// **Example:**
    ///
    /// ```
    /// 537461792068756E6772792C207374617920666F6F6C697368
    /// ```
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}

// MARK: - Hex Decoding

@available(macOS 13.0, *)
extension Data: @retroactive ExpressibleByStringLiteral {
    
    /// Create data from a hex string literal such as `AABBCC1234`.
    /// - Parameter value: The string literal.
    /// - warning: This initializer crashes if the string literal is not a valid hex string.
    /// If you're creating data from strings that are not known at compile time, use ``init(hexString:)`` instead.
    public init(stringLiteral value: StringLiteralType) {
        do {
            try self.init(hexString: "\(value)")
        } catch {
            preconditionFailure("\(error)")
        }
    }

    /// This is the regex used to remove the `0x` prefix from a hex string if present.
    nonisolated(unsafe) private static let hexPrefix = /(0[xX])/

    /// This is the regex used to filter hex input for only characters that compose valid hex values.
    nonisolated(unsafe) private static let hexDenyList = /[^A-Fa-f0-9]/

    /// If input hex string includes any one of these letters or symbols, it will be rejected.
    /// This is important to differentiate between base64 and non-base64 inputs.
    /// Hex inputs are allowed to include spaces and other characters such as `<` and `>`,
    /// but are not allowed to contain letters after `F`, nor the equals sign.
    nonisolated(unsafe) private static let nonHexLetters = /[ghijklmnopqrstuvxyz=]/
    
    /// Create data from a hex string such as `AABBCC1234`.
    /// - Parameter hexString: The hex string.
    /// - throws: This initializer fails if the input is not a valid hex string.
    /// Valid hex strings must be composed of numbers from `0` to `9` and letters from `A` to `F`.
    /// This initializer will accept strings with or without a `0x` prefix, and will ignore whitespaces and newlines.
    /// The string must have an even number of characters, so a string such as `AB1` is not considered valid.
    public init(hexString: String) throws {
        try self.init(Self.bytes(fromHexString: hexString))
    }
    
    /// Interprets a hex string as an array of bytes.
    /// - Parameter hexString: The hex string.
    /// - Returns: An array of bytes represented by the hex string.
    /// Example: if input is `AABB12`, the output will be `[0xAA, 0xBB, 0x12]`.
    public static func bytes(fromHexString hexString: String) throws -> [UInt8] {
        guard !hexString.contains(Self.nonHexLetters) else {
            throw "Invalid hex string: the string contains invalid characters."
        }

        let sanitizedValue = hexString
            .replacing(Self.hexPrefix, with: { _ in "" }) // Remove 0x prefix if present
            .replacing(Self.hexDenyList, with: { _ in "" }) // Remove anything that's not valid hex

        guard sanitizedValue.count % 2 == 0 else {
            throw "Invalid hex string: must have an even number of characters."
        }

        let byteStrings = sanitizedValue.split(every: 2)

        var result = [UInt8]()

        for (index, byte) in byteStrings.enumerated() {
            guard let parsedByte = UInt8(byte, radix: 16) else {
                throw "Invalid byte at index \(index)"
            }
            result.append(parsedByte)
        }

        return result
    }

}
