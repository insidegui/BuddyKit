public extension Collection {
    /// Throws an error if the collection is empty.
    /// - Parameter error: The error to throw if the collection is empty.
    /// - Returns: The non-empty collection (discardable result).
    @discardableResult
    func requireNotEmpty<E: Error>(_ error: E) throws(E) -> Self {
        try isEmpty.requireFalse(error)
        return self
    }

    /// Throws an error if the collection has one or more elements.
    /// - Parameter error: The error to throw if the collection has one or more elements.
    /// - Returns: The empty collection (discardable result).
    @discardableResult
    func requireEmpty<E: Error>(_ error: E) throws(E) -> Self {
        try isEmpty.requireTrue(error)
        return self
    }
}
