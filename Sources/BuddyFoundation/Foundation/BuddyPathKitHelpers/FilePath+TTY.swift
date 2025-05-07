import Foundation
import BuddyPathKit

public extension FilePath {
    /// A path that can be used to represent the standard input/output in command-line arguments.
    static let stdio: FilePath = "-"

    /// `true` if this path is actually the standard input or output (i.e. ``stdio``).
    var isTTY: Bool { string.trimmingCharacters(in: .whitespacesAndNewlines) == "-" }
}
