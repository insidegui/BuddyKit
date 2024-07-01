import Foundation

public extension Bundle {

    /// Reads a typed value from the bundle's Info.plist
    /// - Parameter key: The key to read from.
    /// - Returns: The value for the specified key, `nil` if not found or wrong type.
    ///
    /// Use this method to read data from a Bundle's Info.plist.
    func infoPlistValue<T>(for key: String) -> T? {
        guard let value = infoDictionary?[key] as? T else { return nil }
        return value
    }

    subscript<T>(info key: String) -> T? { infoPlistValue(for: key) }

    subscript(info key: String) -> String? { infoPlistValue(for: key) }
}
