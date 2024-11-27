import Foundation

public extension String {

    /// Assuming the string is a UUID, returns only the first part of the UUID.
    /// If the string is not a UUID, returns the original string.
    ///
    /// This is mostly useful for debugging/log messages.
    ///
    /// Example:
    ///
    /// Input: `9C71CFD3-939D-4F20-899D-F267DA40007F`
    /// Output: `9C71CFD3`
    var shortID: String {
        split(separator: "-").first.flatMap(String.init) ?? self
    }
}

public extension UUID {
    /// See ``Swift/String/shortID``.
    var shortID: String { uuidString.shortID }
}

public extension Identifiable where ID == String {
    /// Assuming the type's `id` is a UUID string, returns only the first part of the `id`.
    ///
    /// See ``Swift/String/shortID``.
    var shortID: String { id.shortID }
}

public extension Identifiable where ID == UUID {
    /// Returns only the first part of the type's `id`.
    ///
    /// See ``Swift/String/shortID``.
    var shortID: String { id.shortID }
}
