import Foundation

public extension Error {

    /// Whether this error is a `Task` cancellation or `URLSession` cancellation error.
    ///
    /// This can be used to potentially ignore cancellation errors for logging and user interface purposes.
    var isCancellation: Bool { self is CancellationError || isURLSessionCancellation }
    
    /// Whether this error is a `URLSession` task cancellation error.
    var isURLSessionCancellation: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == -999
    }
}
