import SwiftUI

/// A button whose action can be defined by a throwing asynchronous function.
///
/// This view behaves similarly to SwiftUI's `Button`, but it allows the action to be an `async throws` function.
///
/// When the user activates the button, it displays a progress indicator until its action returns or throws.
///
/// If the action throws, the button displays the error as an alert using the standard SwiftUI alert modifier,
/// or sets a custom ``AlertContent`` binding to the error alert so that it can be displayed in a custom way.
public struct AsyncButton<Label: View>: View {
    @Binding private var alert: AlertContent
    private var action: () async throws -> Void
    @ViewBuilder private var label: () -> Label

    @State private var internalAlert = AlertContent()
    private let useExternalAlert: Bool
    
    /// Creates an async button that displays a custom label.
    /// - Parameters:
    ///   - alert: A binding to a custom ``AlertContent`` state that will be set if the action throws an error.
    ///   Specify `nil` to have the button configure and display its own alert using the standard SwiftUI alert modifier.
    ///   - action: The throwing asynchronous function that will be run when the user activates the button.
    ///   - label: A custom label view for the button.
    public init(alert: Binding<AlertContent>? = nil,
        action: @escaping () async throws -> Void,
        @ViewBuilder label: @escaping () -> Label)
    {
        if let alert {
            self._alert = alert
            self.useExternalAlert = true
        } else {
            self._alert = .constant(.init())
            self.useExternalAlert = false
        }
        self.action = action
        self.label = label
    }

    @Environment(\.asyncButtonShowProgressIndicator)
    private var showProgressIndicator

    @Environment(\.asyncButtonProgressIndicatorHidesBezel)
    private var progressIndicatorHidesBezel

    @Environment(\.asyncButtonFadeOutAnimation)
    private var fadeOutAnimation

    @Environment(\.asyncButtonFadeInAnimation)
    private var fadeInAnimation

    public var body: some View {
        let hideButton = showProgressIndicator
            && currentTask != nil
            && progressIndicatorHidesBezel

        let progressIndicatorVisible = showProgressIndicator && (currentTask != nil && currentTask?.isCancelled == false)

        ZStack {
            Button {
                guard currentTask == nil || currentTask?.isCancelled == true else { return }

                performAction()
            } label: {
                label()
                    .opacity(progressIndicatorVisible ? 0 : 1)
            }
            .opacity(hideButton ? 0 : 1)
            .disabled(progressIndicatorVisible && progressIndicatorHidesBezel)
            .animation(hideButton ? fadeOutAnimation : fadeInAnimation, value: hideButton)

            if progressIndicatorVisible {
                ProgressView()
                #if os(macOS)
                    .controlSize(.small)
                #endif
            }
        }
        .alert($internalAlert)
    }

    @State private var currentTask: Task<Void, Never>?

    private func performAction() {
        currentTask?.cancel()

        currentTask = Task { @MainActor in
            defer { currentTask = nil }

            do {
                try await action()
            } catch {
                guard !error.isCancellation else { return }

                let content = AlertContent(isPresented: true, title: "Error", message: error.localizedDescription)
                if useExternalAlert {
                    alert = content
                } else {
                    internalAlert = content
                }
            }
        }
    }
}

public extension AsyncButton where Label == Text {

    /// Creates an async button that generates its label from a localized string key.
    /// - Parameters:
    ///   - titleKey: The key for the button’s localized title, that describes the purpose of the button’s action.
    ///   - alert: A binding to a custom ``AlertContent`` state that will be set if the action throws an error.
    ///   Specify `nil` to have the button configure and display its own alert using the standard SwiftUI alert modifier.
    ///   - action: The throwing asynchronous function that will be run when the user activates the button.
    init(_ titleKey: LocalizedStringKey, alert: Binding<AlertContent>? = nil, action: @escaping () async throws -> Void) {
        self.init(alert: alert, action: action) {
            Text(titleKey)
        }
    }

    /// Creates an async button that generates its label from a string.
    /// - Parameters:
    ///   - title: A string that describes the purpose of the button’s action.
    ///   - alert: A binding to a custom ``AlertContent`` state that will be set if the action throws an error.
    ///   Specify `nil` to have the button configure and display its own alert using the standard SwiftUI alert modifier.
    ///   - action: The throwing asynchronous function that will be run when the user activates the button.
    init(_ title: some StringProtocol, alert: Binding<AlertContent>? = nil, action: @escaping () async throws -> Void) {
        self.init(alert: alert, action: action) {
            Text(title)
        }
    }
}

// MARK: - Environment

public extension View {

    /// Configures the visibility of the progress indicator for ``AsyncButton``.
    /// - Parameter hidden: Whether the button should hide its progress indicator.
    /// - Returns: The modified view.
    func buttonProgressIndicatorHidden(_ hidden: Bool = true) -> some View {
        environment(\.asyncButtonShowProgressIndicator, !hidden)
    }
    
    /// Configures the visibility of the ``AsyncButton`` bezel when showing its progress indicator.
    /// - Parameter hide: Whether the button bezel should be hidden when showing the progress indicator.
    /// - Returns: The modified view.
    func buttonProgressIndicatorHidesBezel(_ hide: Bool = true) -> some View {
        environment(\.asyncButtonProgressIndicatorHidesBezel, hide)
    }
}

public extension EnvironmentValues {
    /// Whether ``AsyncButton`` shows a progress indicator while running its action.
    @Entry internal(set) var asyncButtonShowProgressIndicator: Bool = true

    /// Whether ``AsyncButton`` hides the button while running its action.
    @Entry internal(set) var asyncButtonProgressIndicatorHidesBezel: Bool = true

    /// The animation used by ``AsyncButton`` when fading out the button to start running its action.
    @Entry internal(set) var asyncButtonFadeOutAnimation: Animation = .easeOut(duration: 0)

    /// The animation used by ``AsyncButton`` when fading in the button after running its action.
    @Entry internal(set) var asyncButtonFadeInAnimation: Animation = .easeOut(duration: 0.5)
}
