import SwiftUI

#if !os(watchOS)

/// A platform-agnostic version of `UIViewRepresentable`/`NSViewRepresentable`,
/// allowing for a single implementation to be used for both UIKit and AppKit platforms.
public protocol PlatformViewRepresentable: PlatformViewRepresentableType {
    /// The type of view this representable manages.
    associatedtype PlatformViewType
    
    /// Create the platform view.
    /// - Parameter context: SwiftUI context.
    /// - Returns: The new instance of your platform view.
    /// This is equivalent to `makeUIView` on UIKit platforms and `makeNSView` on AppKit platforms.
    func makePlatformView(context: Context) -> PlatformViewType


    /// Update the platform view.
    /// - Parameters:
    ///   - platformView: The platform view instance.
    ///   - context: SwiftUI context.
    /// This is equivalent to `updateUIView` on UIKit platforms and `updateNSView` on AppKit platforms.
    func updatePlatformView(_ platformView: PlatformViewType, context: Context)
}

#if canImport(UIKit)

/// A platform-agnostic version of `UIViewRepresentable`/`NSViewRepresentable`,
/// allowing for a single implementation to be used for both UIKit and AppKit platforms.
public extension PlatformViewRepresentable where UIViewType == PlatformViewType {
    func makeUIView(context: Context) -> UIViewType {
        makePlatformView(context: context)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        updatePlatformView(uiView, context: context)
    }
}

#else

public extension PlatformViewRepresentable where NSViewType == PlatformViewType {
    func makeNSView(context: Context) -> NSViewType {
        makePlatformView(context: context)
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        updatePlatformView(nsView, context: context)
    }
}

#endif // canImport(UIKit)

#endif // os(watchOS)
