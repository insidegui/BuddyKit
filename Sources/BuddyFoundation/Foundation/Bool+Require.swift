public extension Bool {
    /// Throws an error if the bool value is `false`.
    /// - Parameter error: The error to throw if the value is `false`.
    /// - Returns: `true` if the value was true (discardable result).
    @discardableResult
    func require(_ error: Error) throws -> Self {
        guard self else { throw error }
        return self
    }
}
