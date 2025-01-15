import SwiftUI

public extension View {
    /// Makes the view resizable when presented as a sheet.
    /// 
    /// This should be used instead of just `.frame` because on macOS 15 and later sheets are not resizable unless `.presentationSizing(.fitted)`
    /// is specified after the frame. This is a backport so that previous OS versions can be supported whilst adopting the new API.
    @ViewBuilder
    func resizableSheet(minWidth: CGFloat? = nil, maxWidth: CGFloat = .infinity, minHeight: CGFloat? = nil, maxHeight: CGFloat = .infinity) -> some View {
        if #available(macOS 15.0, *) {
            self
                .frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight)
                .presentationSizing(.fitted)
        } else {
            self.frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight)
        }
    }
}
