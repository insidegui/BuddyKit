import Foundation

public extension Optional where Wrapped: Collection {
    /// Returns `true` if the value is `nil` or if the collection is empty.
    var isNilOrEmpty: Bool {
        switch self {
        case .none: true
        case .some(let wrapped): wrapped.isEmpty
        }
    }
}
