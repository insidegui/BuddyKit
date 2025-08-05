import SwiftUI

#if !os(watchOS)

/// A platform-agnostic version of `UIViewControllerRepresentable`/`NSViewControllerRepresentable`,
/// allowing for a single implementation to be used for both UIKit and AppKit platforms.
public protocol PlatformViewControllerRepresentable: PlatformViewControllerRepresentableType {
    /// The type of view controller this representable manages.
    associatedtype PlatformViewControllerType

    /// Create the platform view controller.
    /// - Parameter context: SwiftUI context.
    /// - Returns: The new instance of your platform view controller.
    /// This is equivalent to `makeUIViewController` on UIKit platforms and `makeNSViewController` on AppKit platforms.
    func makePlatformViewController(context: Context) -> PlatformViewControllerType


    /// Update the platform view controller.
    /// - Parameters:
    ///   - platformViewController: The platform view controller instance.
    ///   - context: SwiftUI context.
    /// This is equivalent to `updateUIViewController` on UIKit platforms and `updateNSViewController` on AppKit platforms.
    func updatePlatformViewController(_ platformViewController: PlatformViewControllerType, context: Context)
}

#if canImport(UIKit)

public extension PlatformViewControllerRepresentable where UIViewControllerType == PlatformViewControllerType {
    func makeUIViewController(context: Context) -> UIViewControllerType {
        makePlatformViewController(context: context)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        updatePlatformViewController(uiViewController, context: context)
    }
}

#else

public extension PlatformViewControllerRepresentable where NSViewControllerType == PlatformViewControllerType {
    func makeNSViewController(context: Context) -> NSViewControllerType {
        makePlatformViewController(context: context)
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        updatePlatformViewController(nsViewController, context: context)
    }
}

#endif // canImport(UIKit)

#endif // os(watchOS)
