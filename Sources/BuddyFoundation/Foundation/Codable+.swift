import Foundation
import os

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension JSONEncoder {
    private static let defaultLock = OSAllocatedUnfairLock(initialState: JSONEncoder())

    /// A default `JSONEncoder` used by helper methods in BuddyFoundation when a custom encoder is not specified.
    nonisolated(unsafe) static var `default`: JSONEncoder {
        get { defaultLock.withLock { $0 } }
        set { defaultLock.withLock { $0 = newValue } }
    }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension JSONDecoder {
    private static let defaultLock = OSAllocatedUnfairLock(initialState: JSONDecoder())

    /// A default `JSONDecoder` used by helper methods in BuddyFoundation when a custom encoder is not specified.
    nonisolated(unsafe) static var `default`: JSONDecoder {
        get { defaultLock.withLock { $0 } }
        set { defaultLock.withLock { $0 = newValue } }
    }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension PropertyListEncoder {
    private static let defaultLock = OSAllocatedUnfairLock(initialState: PropertyListEncoder())

    /// A default `PropertyListEncoder` used by helper methods in BuddyFoundation when a custom encoder is not specified.
    nonisolated(unsafe) static var `default`: PropertyListEncoder {
        get { defaultLock.withLock { $0 } }
        set { defaultLock.withLock { $0 = newValue } }
    }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension PropertyListDecoder {
    private static let defaultLock = OSAllocatedUnfairLock(initialState: PropertyListDecoder())

    /// A default `PropertyListDecoder` used by helper methods in BuddyFoundation when a custom encoder is not specified.
    nonisolated(unsafe) static var `default`: PropertyListDecoder {
        get { defaultLock.withLock { $0 } }
        set { defaultLock.withLock { $0 = newValue } }
    }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension Decodable {
    /// Decodes a value of this type from a JSON file.
    /// - Parameters:
    ///   - file: Path to JSON file.
    ///   - decoder: Custom `JSONDecoder` to use.
    init(jsonAt file: FilePath, decoder: JSONDecoder = .default) throws {
        let data = try file.read()
        self = try decoder.decode(Self.self, from: data)
    }

    /// Decodes a value of this type from a property list file.
    /// - Parameters:
    ///   - file: Path to property list file.
    ///   - decoder: Custom `PropertyListDecoder` to use.
    init(propertyListAt file: FilePath, decoder: PropertyListDecoder = .default) throws {
        let data = try file.read()
        self = try decoder.decode(Self.self, from: data)
    }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension Encodable {
    /// Encodes the value to a JSON file.
    /// - Parameters:
    ///   - file: Path to JSON file.
    ///   - encoder: Custom `JSONEncoder` to use.
    func encodeJSON(to file: FilePath, encoder: JSONEncoder = .default) throws {
        let data = try encoder.encode(self)
        try file.write(data)
    }

    /// Encodes the value to a property list file.
    /// - Parameters:
    ///   - file: Path to property list file.
    ///   - encoder: Custom `PropertyListEncoder` to use.
    func encodePropertyList(to file: FilePath, encoder: PropertyListEncoder = .default) throws {
        let data = try encoder.encode(self)
        try file.write(data)
    }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension FilePath {
    /// Decodes a `Decodable` type from a JSON file.
    /// - Parameter decoder: A custom `JSONDecoder` to use.
    /// - Returns: The value decoded from the file.
    func decodedJSON<T>(decoder: JSONDecoder = .default) throws -> T where T: Decodable {
        try T.init(jsonAt: self, decoder: decoder)
    }

    /// Decodes a `Decodable` type from a property list file.
    /// - Parameter decoder: A custom `PropertyListDecoder` to use.
    /// - Returns: The value decoded from the file.
    func decodedPropertyList<T>(decoder: PropertyListDecoder = .default) throws -> T where T: Decodable {
        try T.init(propertyListAt: self, decoder: decoder)
    }

    /// Encodes a value to a JSON file.
    /// - Parameters:
    ///   - value: The value to encode.
    ///   - encoder: A custom `JSONEncoder` to use.
    func encodeJSON<T>(_ value: T, encoder: JSONEncoder = .default) throws where T: Encodable {
        try value.encodeJSON(to: self, encoder: encoder)
    }

    /// Encodes a value to a property list file.
    /// - Parameters:
    ///   - value: The value to encode.
    ///   - encoder: A custom `PropertyListEncoder` to use.
    func encodePropertyList<T>(_ value: T, encoder: PropertyListEncoder = .default) throws where T: Encodable {
        try value.encodePropertyList(to: self, encoder: encoder)
    }
}
