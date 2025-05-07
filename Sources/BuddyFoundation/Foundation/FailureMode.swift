/// A type used to indicate how an API handles failures.
///
/// This type can be used in API that performs multiple throwing operations to give the caller
/// control over how the API handles failures in one or more of its operations.
///
/// The ``FailureMode/open`` mode will continue to process additional operations if one or more child operations fail.
/// The ``FailureMode/closed`` mode will stop and throw as soon as any child operation fails.
public enum FailureMode: Sendable, Hashable {
    /// A failure in one or more steps still allows the operation to continue.
    case open
    /// A failure in a single step interrupts the operation.
    case closed
}
