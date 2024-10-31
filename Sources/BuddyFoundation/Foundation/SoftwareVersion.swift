import Foundation

/// Type-safe representation for software version formatted as `major.minor.patch`.
///
/// This type encapsulates a software version, which can be a version of your app, or an operating system version.
///
/// It conforms to `Comparable`, making it easy to compare different software versions, such as when doing compatibility checks, for example.
///
/// ## String Support
///
/// ``SoftwareVersion`` can be initialized with a string using ``init(string:)``, a failable initializer that will reject invalid version strings.
/// For defining software versions directly in code, you may take advantage of its conformance to `ExpressibleByStringLiteral`,
/// initializing it directly from a string:
///
/// ```swift
/// let version: SoftwareVersion = "2.0"
/// ```
///
/// ## Codable Support
///
/// ``SoftwareVersion`` can be used directly as a member of types that conform to `Encodable`/`Decodable`.
/// It uses a single value container that encodes the version as a string, so a value like `SoftwareVersion(major: 2, minor: 1, patch: 3)` would be encoded as the string `2.1.3`.
public struct SoftwareVersion: Hashable, CustomStringConvertible, ExpressibleByStringLiteral, Codable, Comparable, Sendable {

    /// The major version number (ex: the `2` in `2.3.1`).
    public let major: Int

    /// The minor version number (ex: the `3` in `2.3.1`).
    public let minor: Int

    /// The patch version number (ex: the `1` in `2.3.1`).
    public let patch: Int

    /// An empty version (i.e. `0.0.0`).
    public static let empty = SoftwareVersion(major: 0, minor: 0, patch: 0)
    
    /// Initializes the software version with `major`, `minor`, and `patch` version numbers.
    /// - Parameters:
    ///   - major: The major version number (ex: the `2` in `2.3.1`).
    ///   - minor: The minor version number (ex: the `3` in `2.3.1`).
    ///   - patch: The patch version number (ex: the `1` in `2.3.1`).
    public init(major: Int, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    /// Initializes the software version by taking just the major version number from another software version.
    /// - Parameter other: The software version to extract the major version from.
    ///
    /// Use this method when you'd like to compare just the major version number between versions.
    /// You can initialize a new software version that takes just the major number from another one,
    /// then use the new instance in your comparison.
    public init(majorVersionFrom other: SoftwareVersion) {
        self.init(major: other.major, minor: 0, patch: 0)
    }
}

public extension SoftwareVersion {
    
    /// Initializes a software version from a string literal representation such as `"2.0"` or `"2.3.1"`.
    /// - Parameter value: The string literal representing a software version.
    /// - warning: This initializer causes a precondition failure if the string is not a valid software version.
    /// If you're initializing ``SoftwareVersion`` with dynamic strings that might contain invalid data,
    /// use ``init(string:)`` instead, which is a failable initializer.
    init(stringLiteral value: StringLiteralType) {
        guard let version = SoftwareVersion(string: String(value)) else {
            preconditionFailure("Invalid software version: \"\(value)\".")
        }
        self = version
    }
    
    /// Initializes a software version from a string literal representation such as `"2.0"` or `"2.3.1"`.
    /// - Parameter string: The string representing a software version.
    /// This initializer fails if the string does not represent a valid software version.
    /// - note: Use this initializer when there's a possibility that the string might contain an invalid software version,
    /// such as when the string is coming from a user interface or remote API. If you know at compile time that the string
    /// is a valid software version, you may use ``init(stringLiteral:)``.
    init?(string: String) {
        let components = string
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: ".")

        guard !components.isEmpty else { return nil }
        guard let major = Int(components[0]) else { return nil }

        self.major = major

        if components.count > 1 {
            self.minor = Int(components[1]) ?? 0
        } else {
            self.minor = 0
        }

        if components.count > 2 {
            self.patch = Int(components[2]) ?? 0
        } else {
            self.patch = 0
        }
    }

}

public extension SoftwareVersion {
    /// A description that looks more like what a user would expect to see.
    ///
    /// Examples:
    /// - `14.0.0` =  `14`
    /// - `15.1.0`= `15.1`
    var shortDescription: String {
        guard patch == 0 else { return stringRepresentation }
        guard minor == 0 else { return String(format: "%d.%d", major, minor) }
        return String(format: "%d", major)
    }
}

extension SoftwareVersion {
    public var description: String { stringRepresentation }
    private var stringRepresentation: String { String(format: "%d.%d.%d", major, minor, patch) }
}

public extension SoftwareVersion {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let str = try container.decode(String.self)
        self = try SoftwareVersion(string: str)
            .require(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid software version string: \"\(str)\".")))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringRepresentation)
    }

}

public extension SoftwareVersion {

    static func >(lhs: SoftwareVersion, rhs: SoftwareVersion) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch > rhs.patch
            }

            return lhs.minor > rhs.minor
        } else {
            return lhs.major > rhs.major
        }
    }

    static func <(lhs: SoftwareVersion, rhs: SoftwareVersion) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch < rhs.patch
            }

            return lhs.minor < rhs.minor
        } else {
            return lhs.major < rhs.major
        }
    }

    static func >=(lhs: SoftwareVersion, rhs: SoftwareVersion) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch >= rhs.patch
            }

            return lhs.minor >= rhs.minor
        } else {
            return lhs.major >= rhs.major
        }
    }

    static func <=(lhs: SoftwareVersion, rhs: SoftwareVersion) -> Bool {
        if lhs.major == rhs.major {
            if lhs.minor == rhs.minor {
                return lhs.patch <= rhs.patch
            }

            return lhs.minor <= rhs.minor
        } else {
            return lhs.major <= rhs.major
        }
    }

}
