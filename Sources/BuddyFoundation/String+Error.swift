import Foundation

extension String: @retroactive LocalizedError {

    /// Sometimes you just want to throw an arbitrary error message.
    /// This extension adds `LocalizedError` conformance to `String` in order to allow that.
    public var errorDescription: String? { self }
    
    /// Sometimes you just want to throw an arbitrary error message.
    /// This extension adds `LocalizedError` conformance to `String` in order to allow that.
    public var failureReason: String? { self }

}
