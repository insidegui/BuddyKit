public extension Bool {
    /// Throws an error if the bool value is `false`.
    /// - Parameter error: The error to throw if the value is `false`.
    /// - Returns: `true` if the value was `true` (discardable result).
    @discardableResult
    func require<E: Error>(_ error: E) throws(E) -> Self {
        guard self else { throw error }
        return true
    }

    /// Throws an error if the bool value is `false`.
    /// - Parameter error: The error to throw if the value is `false`.
    /// - Returns: `true` if the value was true (discardable result).
    @discardableResult
    func requireTrue<E: Error>(_ error: E) throws(E) -> Self {
        guard self else { throw error }
        return true
    }

    /// Throws an error if the bool value is `true`.
    /// - Parameter error: The error to throw if the value is `false`.
    /// - Returns: `true` if the value was `false` (discardable result).
    @discardableResult
    func requireFalse<E: Error>(_ error: E) throws(E) -> Self {
        guard !self else { throw error }
        return true
    }
}

public extension Optional where Wrapped == Bool {
    /// Throws an error if the wrapped bool value is `false` or if the optional is `nil`.
    /// - Parameter error: The error to throw if the wrapped value is `false` or the optional is `nil`.
    /// - Returns: `true` if the wrapped value was `true` (discardable result).
    @discardableResult
    func requireTrue<E: Error>(_ error: E) throws(E) -> Bool {
        guard let self else { throw error }
        guard self else { throw error }
        return true
    }

    /// Throws an error if the wrapped bool value is `true` or if the optional is `nil`.
    /// - Parameter error: The error to throw if the wrapped value is `true` or the optional is `nil`.
    /// - Returns: `true` if the wrapped value was `false` (discardable result).
    @discardableResult
    func requireFalse<E: Error>(_ error: E) throws(E) -> Bool {
        guard let self else { throw error }
        guard !self else { throw error }
        return true
    }
}
