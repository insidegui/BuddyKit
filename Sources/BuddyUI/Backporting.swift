import SwiftUI

public extension View {
    /// Applies the grouped form style on macOS 13 and later.
    /// On previous OSes, applies a padding unless padding is set to zero.
    @ViewBuilder
    func groupedFormStyle(_ enabled: Bool = true, legacyPadding: CGFloat? = nil) -> some View {
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
            formStyle(.grouped)
        } else {
            if let legacyPadding {
                /// Custom padding or zero.
                padding(legacyPadding)
            } else {
                /// System-default padding.
                padding()
            }
        }
    }
}
