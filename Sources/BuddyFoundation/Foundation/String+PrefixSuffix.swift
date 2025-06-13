import Foundation

public extension String {
    /// Returns the string with its first character lowercased.
    func lowercasingFirstCharacter() -> String {
        if count > 1 {
            prefix(1).lowercased() + dropFirst()
        } else {
            lowercased()
        }
    }

    /// Returns the string with its first character uppercased.
    func uppercasingFirstCharacter() -> String {
        if count > 1 {
            prefix(1).uppercased() + dropFirst()
        } else {
            uppercased()
        }
    }

    /// Returns the string with the specified prefix removed.
    /// - Parameter prefix: The prefix to remove from the string.
    /// - Returns: The string with the prefix removed. If the string doesn't have the prefix, returns the same string.
    func removingPrefix(_ prefix: String) -> String {
        if count > prefix.count, hasPrefix(prefix) {
            String(dropFirst(prefix.count))
        } else {
            self
        }
    }

    /// Returns the string with the specified suffix removed.
    /// - Parameter suffix: The suffix to remove from the string.
    /// - Returns: The string with the suffix removed. If the string doesn't have the suffix, returns the same string.
    func removingSuffix(_ suffix: String) -> String {
        if count > suffix.count, hasSuffix(suffix) {
            String(dropLast(suffix.count))
        } else {
            self
        }
    }
}
