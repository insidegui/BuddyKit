import Foundation

public struct PlatformImageError {
    public private(set) var message: String

    internal init(_ message: String) {
        self.message = message
    }
}

extension PlatformImageError: LocalizedError {
    public var errorDescription: String? { message }
    public var failureReason: String? { message }
}

extension PlatformImageError: CustomStringConvertible {
    public var description: String { message }
}
