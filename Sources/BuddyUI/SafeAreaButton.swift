import SwiftUI

public extension View {

    /// Adds a button to the bottom safe area of the modified view.
    /// - Parameters:
    ///   - spacing: How much spacing to place between the button and the top of the safe area, as well as the top of the safe area to the modified view.
    ///   - button: Use this view builder to provide the button that should be placed on the safe area. The button is automatically configured with a standard style for safe area buttons.
    /// - Returns: The modified view.
    ///
    /// Use this view modifier when you'd like to have a button that stays put at the bottom of the screen.
    /// This is especially useful for scrollable forms, such as when using the grouped form style on macOS, or forms in general on mobile platforms.
    /// Having a button always visible at the bottom of the screen can be helpful to users.
    ///
    /// - note: You may add more than one button to the safe area by providing an `HStack` or `VStack` with multiple buttons in the view builder.
    /// For example, if you'd like to have "Cancel" and "Save" buttons on macOS, you might want to place them within an `HStack` with a `Spacer` in between,
    /// so that the "Cancel" button is all the way to the right, and the "Save" button is all the way to the left.
    func safeAreaButton<ButtonContent: View>(spacing: CGFloat = 16, @ViewBuilder _ button: @escaping () -> ButtonContent) -> some View {
        modifier(SafeAreaButton(spacing: spacing, button: button))
    }
}

private struct SafeAreaButton<ButtonContent: View>: ViewModifier {
    var spacing: CGFloat
    @ViewBuilder var button: () -> ButtonContent

    init(spacing: CGFloat = 16, @ViewBuilder button: @escaping () -> ButtonContent) {
        self.spacing = spacing
        self.button = button
    }

    package func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: spacing) {
                ZStack {
                    button()
                        #if os(macOS)
                        .controlSize(.large)
                        .padding()
                        #else
                        .padding(.vertical, spacing)
                        .buttonStyle(.safeArea)
                        .padding(.horizontal, 32)
                        #endif
                }
                #if os(macOS)
                .frame(maxWidth: .infinity, alignment: .trailing)
                #else
                .frame(maxWidth: .infinity)
                #endif
                .background(Material.ultraThin)
                .overlay(alignment: .top) {
                    Divider()
                }
            }
    }
}

private struct SafeAreaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.horizontal, 64)
            .padding(.vertical, 8)
            .foregroundStyle(Color.white)
            .background(shape.foregroundStyle(.tint))
            .overlay(Color.white.opacity(configuration.isPressed ? 0.2 : 0))
            .clipShape(shape)
    }

    private var shape: some InsettableShape {
        Capsule(style: .continuous)
    }
}

private extension ButtonStyle where Self == SafeAreaButtonStyle {
    static var safeArea: SafeAreaButtonStyle { SafeAreaButtonStyle() }
}

#if DEBUG
@available(macOS 13, iOS 16, tvOS 16, *)
#Preview {
    Form {
        TextField("Field", text: .constant("Hello"))
        TextField("Field 2", text: .constant("Hello 2"))
        TextField("Field 3", text: .constant("Hello 3"))
    }
    .formStyle(.grouped)
    .navigationTitle(Text("Safe Area Button"))
    .safeAreaButton {
        Button {
            print("Tapped \(Date.now.timeIntervalSince1970)")
        } label: {
            Text("Generate")
        }
        .keyboardShortcut(.defaultAction)
    }
}
#endif
