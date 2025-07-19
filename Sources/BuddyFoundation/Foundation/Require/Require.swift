import Foundation

/// Attempts to cast a value to a specific type, throwing an error if casting fails.
/// - Parameters:
///   - value: The value to be cast.
///   - type: The type ot attempt to cast the value to.
///   - error: The error to throw if casting the value fails.
/// - Throws: The specified error if casting fails.
/// - Returns: The value cast to the specified type.
///
/// This overload is provided for use where the type can not be inferred by the compiler, allowing the type to be specified manually.
@_disfavoredOverload
@discardableResult
public func cast<T, E: Error>(_ value: @autoclosure () -> Any?, as type: T.Type, _ error: E) throws(E) -> T {
    try cast(value(), error: error)
}

/// Attempts to cast a value to the expected type, throwing an error if casting fails.
/// - Parameters:
///   - value: The value to be cast.
///   - error: The error to throw if casting the value fails.
/// - Throws: The specified error if casting fails.
/// - Returns: The value cast to the expected type.
///
/// This overload is provided for use where the type can be inferred by the compiler.
@discardableResult
public func cast<T, E: Error>(_ value: @autoclosure () -> Any?, error: E) throws(E) -> T {
    let rawValue = try value().require(error)
    guard let cast = rawValue as? T else { throw error }
    return cast
}
