import SwiftUI

/// Wraps a view in such a way that it can be used as a form sheet with cancellation and confirmation buttons.
/// Creates a custom bottom bar on macOS sheets and automatically wraps contents in a navigation view on iOS.
public struct FormSheet<Content: View>: View {
    public var cancellationTitle: LocalizedStringKey
    public var confirmationTitle: LocalizedStringKey
    public var dismissOnConfirm: Bool
    public var onConfirm: (() -> Void)
    @ViewBuilder public var content: () -> Content

    public init(cancellationTitle: LocalizedStringKey = "Cancel", confirmationTitle: LocalizedStringKey = "Done", dismissOnConfirm: Bool = false, onConfirm: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.cancellationTitle = cancellationTitle
        self.confirmationTitle = confirmationTitle
        self.dismissOnConfirm = dismissOnConfirm
        self.onConfirm = onConfirm
        self.content = content
    }

    @Environment(\.dismiss)
    private var dismiss

    private func cancel() {
        dismiss()
    }

    private func confirm() {
        onConfirm()
        if dismissOnConfirm { dismiss() }
    }

    public var body: some View {
        #if os(macOS)
        /// Apply modifiers for macOS.
        content()
            .safeAreaInset(edge: .bottom, spacing: 8) {
                HStack {
                    Button(cancellationTitle, action: cancel)
                        .keyboardShortcut(.cancelAction)

                    Spacer()

                    Button(confirmationTitle, action: confirm)
                        .keyboardShortcut(.defaultAction)
                }
                .padding()
                .background {
                    Rectangle()
                        .foregroundStyle(Material.thick)
                        .overlay(alignment: .top) {
                            Divider()
                        }
                }
            }
        #else // os(macOS)
        /// Apply modifiers for iOS and friends.
        NavigationView {
            content()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        Button(cancellationTitle, action: cancel)
                    }

                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button(confirmationTitle, action: confirm)
                    }
                }
        }
        #endif // os(macOS)
    }
}

public extension View {

    /// Set the enabled state of the confirmation button for the ``FormSheet`` wrapping this view.
    /// - Parameter enabled: Whether the confirmation button should be enabled.
    /// - Returns: The modified view.
    func formSheetConfirmationButtonEnabled(_ enabled: Bool) -> some View {
        environment(\.formSheetConfirmationButtonEnabled, enabled)
    }

    /// Set the enabled state of the cancellation button for the ``FormSheet`` wrapping this view.
    /// - Parameter enabled: Whether the cancellation button should be enabled.
    /// - Returns: The modified view.
    func formSheetCancellationButtonEnabled(_ enabled: Bool) -> some View {
        environment(\.formSheetCancellationButtonEnabled, enabled)
    }

    /// Set the enabled state of both confirmation and cancellation buttons for the ``FormSheet`` wrapping this view.
    /// - Parameter enabled: Whether the form sheet buttons should be enabled.
    /// - Returns: The modified view.
    func formSheetButtonsEnabled(_ enabled: Bool) -> some View {
        formSheetConfirmationButtonEnabled(enabled)
            .formSheetCancellationButtonEnabled(enabled)
    }
}

private struct FormSheetConfirmationButtonEnabledEnvironmentKey: EnvironmentKey {
    static var defaultValue = true
}
private extension EnvironmentValues {
    var formSheetConfirmationButtonEnabled: Bool {
        get { self[FormSheetConfirmationButtonEnabledEnvironmentKey.self] }
        set { self[FormSheetConfirmationButtonEnabledEnvironmentKey.self] = newValue }
    }
}

private struct FormSheetCancellationButtonEnabledEnvironmentKey: EnvironmentKey {
    static var defaultValue = true
}
private extension EnvironmentValues {
    var formSheetCancellationButtonEnabled: Bool {
        get { self[FormSheetCancellationButtonEnabledEnvironmentKey.self] }
        set { self[FormSheetCancellationButtonEnabledEnvironmentKey.self] = newValue }
    }
}

#if DEBUG
private struct FormContentPreview: View {
    var body: some View {
        FormSheet {
            print("onConfirm")
        } content: {
            Form {
                TextField("Text Field", text: .constant("text value"))
                Toggle("Toggle", isOn: .constant(true))
            }
            .groupedFormStyle()
            .navigationTitle(Text("Form Sheet"))
        }
    }
}

private struct FormSheetPreview: View {
    #if os(macOS)
    @State private var sheetPresented = false
    #else
    @State private var sheetPresented = true
    #endif

    var body: some View {
        Button("Toggle Sheet") {
            sheetPresented.toggle()
        }
        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        .sheet(isPresented: $sheetPresented, onDismiss: { print("onDismiss") }) {
            FormContentPreview()
        }
    }
}

#Preview("Presentation") {
    FormSheetPreview()
}

#Preview("Sheet Content") {
    FormContentPreview()
}
#endif
