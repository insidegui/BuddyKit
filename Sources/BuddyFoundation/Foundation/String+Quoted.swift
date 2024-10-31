import Foundation

public extension String {
    /// Returns the string in between quotes, mostly useful for debug/log messages.
    var quoted: String { "\"\(self)\"" }
}
