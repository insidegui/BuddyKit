import Foundation

public extension String {

    /// Sometimes you just want to throw an arbitrary error message.
    /// This extension adds `LocalizedError` conformance to `String` in order to allow that.
    var errorDescription: String? { self }
    
    /// Sometimes you just want to throw an arbitrary error message.
    /// This extension adds `LocalizedError` conformance to `String` in order to allow that.
    var failureReason: String? { self }

}

extension String: @retroactive LocalizedError { }
