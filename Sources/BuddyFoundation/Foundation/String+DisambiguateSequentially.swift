import Foundation

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 10.0, *)
public extension String {

    /// Finds the next unambiguous string for the current string by comparing it against a collection of strings.
    /// - Parameter siblings: A collection containing strings that the current string must be disambiguated against.
    /// - Parameter caseSensitive: By default, the function checks for ambiguity using a case-insensitive comparison.
    /// Set this to `true` to only consider a string ambiguous if there's an exact match.
    /// - Parameter separator: An optional separator to use between the string prefix and the disambiguating number.
    /// If `nil`, the function will use a space as the separator, but only if the sibling that collides with the string already contains spaces.
    /// - Returns: The disambiguated string by incrementing a counter suffix.
    ///
    /// Use this function when you have a collection of strings (file names in a directory, for example) and there's a need to ensure that the current
    /// string won't conflict with an existing item in the collection.
    ///
    /// For example, assuming the string `file2` and a collection containing the strings `file1`, `file2`, and `file3`,
    /// calling this function on the string `file2` would return `file4`, which is the next unambiguous value for the collection.
    ///
    /// Assuming the same collection of strings, calling this function on `file7` would just return `file7`, as it's already unambiguous.
    ///
    /// - warning: This function is designed for use with small collections.
    func disambiguatedSequentially<S: Collection>(with siblings: S, caseSensitive: Bool = false, separator: String? = nil) -> String where S.Iterator.Element == String {
        func isAmbiguous(_ value: String) -> Bool {
            if caseSensitive {
                siblings.contains(where: { $0.localizedCompare(value) == .orderedSame })
            } else {
                siblings.contains(where: { $0.localizedCaseInsensitiveCompare(value) == .orderedSame })
            }
        }

        guard isAmbiguous(self) else { return self }

        let match = siblings
            .compactMap { resolveSequence(with: $0) }
            .max(by: { $0.count < $1.count })

        if let match {
            var disambiguated = if let separator {
                "\(match.prefix.removingSuffix(separator))\(separator)\(match.count + 1)"
            } else {
                /// Avoid adding a space between the name and the count unless the name already has spaces.
                if match.prefix.components(separatedBy: .whitespaces).count > 1 {
                    "\(match.prefix)\(match.count + 1)"
                } else {
                    "\(match.prefix.trimmingCharacters(in: .whitespaces))\(match.count + 1)"
                }
            }

            /// If for some reason there's still ambiguity after the initial update, increment the counter
            /// in the disambiguated value until it is no longer ambiguous.
            let maxIterations = 1000
            var fallback = 0
            while isAmbiguous(disambiguated) {
                fallback += 1

                guard let value = disambiguated.incrementingSequence(by: 1, fallbackValue: fallback) else {
                    assertionFailure("Couldn't disambiguate \(disambiguated.quoted)")
                    return disambiguated
                }

                disambiguated = value

                guard fallback < maxIterations else {
                    assertionFailure("Something is seriously wrong. Couldn't disambiguate after \(maxIterations) iterations.")
                    return disambiguated
                }
            }

            return disambiguated
        } else {
            return self
        }
    }

}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 10.0, *)
private extension String {
    nonisolated(unsafe) private static let sequentialNameRegex = /([.[^0-9]]{1,})([0-9]{1,})?/

    func resolveSequence(with other: String) -> (prefix: String, count: Int)? {
        guard let myMatch = try? Self.sequentialNameRegex.firstMatch(in: self) else { return nil }
        guard let theirMatch = try? Self.sequentialNameRegex.firstMatch(in: other) else { return nil }

        guard myMatch.output.1.localizedCaseInsensitiveCompare(theirMatch.output.1) == .orderedSame else { return nil }

        if let countString = theirMatch.output.2, let count = Int(countString) {
            return (String(myMatch.output.1), count)
        } else {
            /// A sibling without a count is considered as count zero.
            return (String(myMatch.output.1), 0)
        }
    }

    func incrementingSequence(by increment: Int = 1, fallbackValue: Int = 1) -> String? {
        guard let match = try? Self.sequentialNameRegex.firstMatch(in: self) else { return nil }
        guard let countString = match.output.2, let count = Int(countString) else { return "\(self)\(fallbackValue)" }

        return "\(match.output.1)\(count + increment)"
    }

}
