import Foundation
import Combine

/// A property wrapper for a value that's backed by a `PassthroughSubject`,
/// exposing a publisher as its projected value so that it can be observed externally.
///
/// This is especially useful in an `ObservableObject` implementation where using `@Published`
/// would cause too much view updates if the object is used as an environment object in SwiftUI.
///
/// Instead of using `@Published`, use `@SubjectPublisher`.
///
/// In the object, set the value as you normally would, but in order to receive updates in SwiftUI views,
/// those will have to observe the projected value of the property using `onReceive()`.
///
/// ## Example:
///
/// ```swift
/// final class MyObject: ObservableObject {
///     @SubjectPublisher private(set) var count = 0
///
///     func updateState() {
///         count += 1
///     }
/// }
///
/// struct MyView: View {
///     @EnvironmentObject private var object: MyObject
///
///     @State private var count = 0
///
///     var body: some View {
///         Text(count, format: .number)
///             .onReceive(object.$count) { count = $0 }
///     }
/// }
/// ```
///
/// - note: This is provided mainly for projects that can't adopt `@Observable`.
@propertyWrapper
public struct SubjectPublisher<Value> {
    private let subject = PassthroughSubject<Value, Never>()
    
    /// The current value of the property.
    public var wrappedValue: Value {
        didSet {
            subject.send(wrappedValue)
        }
    }
    
    /// A publisher that produces a new value when `wrappedValue` is set.
    public var projectedValue: AnyPublisher<Value, Never> { subject.eraseToAnyPublisher() }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
