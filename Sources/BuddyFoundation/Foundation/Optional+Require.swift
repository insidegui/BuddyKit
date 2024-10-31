public extension Optional {
    /// Unwraps the optional, throwing an error if its value is `nil`.
    /// - Parameter error: The error to throw in case the optional is `nil`.
    /// - Returns: The unwrapped value.
    @discardableResult
    func require(_ error: Error) throws -> Wrapped {
        guard let self else { throw error }
        return self
    }
}

// MARK: - Deprecated

public extension Optional {
    /// Unwraps the optional, throwing an error if its value is `nil`.
    /// - Parameter error: The error to throw in case the optional is `nil`.
    /// - Returns: The unwrapped value.
    @available(*, deprecated, renamed: "require", message: "Renamed to \"require\".")
    func unwrap(_ error: Error) throws -> Wrapped {
        guard let self else { throw error }
        return self
    }
}
