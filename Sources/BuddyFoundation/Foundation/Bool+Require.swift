public extension Bool {
    @discardableResult
    func require(_ error: Error) throws -> Self {
        guard self else { throw error }
        return self
    }
}
