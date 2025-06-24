import Foundation
import os

/// A property wrapper that uses a lock to protect its value from concurrent reads/writes.
///
/// - warning: This is not appropriate for atomic operations. Use it for protecting class properties that might be accessed from multiple actors or queues.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@propertyWrapper public struct Lock<T: Sendable>: Sendable {

    private let _value: OSAllocatedUnfairLock<T>

    public var wrappedValue: T {
        get {
            _value.withLock { $0 }
        }
        nonmutating set {
            _value.withLock { $0 = newValue }
        }
    }

    public init(wrappedValue: T) {
        self._value = OSAllocatedUnfairLock(initialState: wrappedValue)
    }
}
