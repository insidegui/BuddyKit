import Foundation

public extension String {
    /// Creates a description of the optional value with a placeholder for when the value is `nil`.
    /// - Parameters:
    ///   - value: The optional value.
    ///   - nilString: The string to be used when the value is `nil`.
    ///
    /// This is primarily designed for debugging where you want a cleaner output rather than the default `Optional(...)` description.
    init<T>(optional value: Optional<T>, _ nilString: String = "<nil>") {
        self = switch value {
        case .none: nilString
        case .some(let wrapped): String(describing: wrapped)
        }
    }

    /// Creates a description of the optional value with a placeholder for when the value is `nil`.
    /// - Parameters:
    ///   - value: The optional value.
    ///   - nilPlaceholder: A value to use when the input value is `nil`.
    ///
    /// This is primarily designed for debugging where you want a cleaner output rather than the default `Optional(...)` description.
    @_disfavoredOverload
    init<T>(optional value: Optional<T>, _ nilPlaceholder: T) {
        self = switch value {
        case .none: String(describing: nilPlaceholder)
        case .some(let wrapped): String(describing: wrapped)
        }
    }
}
