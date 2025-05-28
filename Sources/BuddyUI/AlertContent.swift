import SwiftUI
internal import BuddyFoundation

/// Content that can be presented as an alert in a SwiftUI view.
///
/// This type represents content that can be displayed in an alert within a SwiftUI view, typically used for displaying error messages.
///
/// You can set the value of one of your view's `@State` properties to an empty `AlertContent` value, then set the property
/// to an `AlertContent` initialized with ``AlertContent/init(_:title:)`` in a `catch` block to automatically present
/// an error to the user when it occurs.
///
/// This type is also leveraged by ``AsyncButton`` and `throwingTask`.
public struct AlertContent: Equatable, Sendable {
    public var isPresented: Bool
    public var title: Text
    public var message: Text?
    public var buttonTitle: Text

    public init(isPresented: Bool = false, title: LocalizedStringKey = "Error", message: LocalizedStringKey? = nil, buttonTitle: LocalizedStringKey = "OK") {
        self.isPresented = isPresented
        self.title = Text(title)
        self.message = message.flatMap { Text($0) }
        self.buttonTitle = Text(buttonTitle)
    }

    @_disfavoredOverload
    public init(isPresented: Bool = false, title: LocalizedStringKey = "Error", message: String? = nil, buttonTitle: LocalizedStringKey = "OK") {
        self.isPresented = isPresented
        self.title = Text(title)
        self.message = message.flatMap { Text($0) }
        self.buttonTitle = Text(buttonTitle)
    }
}

public extension AlertContent {

    /// Creates alert content presenting the specified error.
    /// - Parameter error: The error that will be represented in the alert content.
    /// - Parameter title: A custom title for the alert.
    ///
    /// Use this initializer to create alert content that's presenting an error message corresponding to the specified error.
    ///
    /// This can be useful for example if you're catching an error inside a view implementation and would like to automatically
    /// display an error alert to the user whenever an error occurs:
    ///
    /// ```swift
    /// struct MyView: View {
    ///     @State private var alert = AlertContent()
    ///
    ///     var body: some View {
    ///         Button("Throw") {
    ///             do {
    ///                 throw "Test error"
    ///             } catch {
    ///                 alert = AlertContent(error)
    ///             }
    ///         }
    ///         .alert($alert)
    ///     }
    /// }
    /// ```
    init(_ error: Error, title: LocalizedStringKey = "Error") {
        self.init(
            isPresented: true,
            title: title,
            message: error.localizedDescription
        )
    }
    
    /// Initializes an empty alert content.
    ///
    /// Use this initializer as the initial value for an `@State` property in a view where you'd like to present alerts in the future.
    ///
    /// Since ``AlertContent/isPresented`` is initialized as `false`, no alert will be presented by default.
    /// You may present the alert by setting ``AlertContent/isPresented`` to `true` or setting the state property
    /// value to a new `AlertContent` initialized with ``AlertContent/init(_:title:)``, for example.
    init() {
        self.init(isPresented: false, title: "Error", message: nil)
    }
}

public extension View {
    func alert(_ content: Binding<AlertContent>) -> some View {
        self.alert(content.wrappedValue.title, isPresented: content.isPresented) {
            Button {
                content.wrappedValue.isPresented = false
            } label: {
                content.wrappedValue.buttonTitle
            }
        } message: {
            if let message = content.wrappedValue.message {
                message
            }
        }
    }
}

#if DEBUG
private struct MyView: View {
    @State private var alert = AlertContent()

    var body: some View {
        Button("Throw") {
            do {
                throw "Test error"
            } catch {
                alert = AlertContent(error)
            }
        }
        .alert($alert)
    }
}

#Preview {
    MyView()
        .padding()
}
#endif
