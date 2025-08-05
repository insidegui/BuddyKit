import SwiftUI

/// Generic wrapper for a platform view to be embedded in a SwiftUI view hierarchy.
///
/// This view can be used to wrap any `UIView` in UIKit or any `NSView` in AppKit for inclusion in a SwiftUI view hierarchy.
///
/// > Tip: Use this type to embed a platform-native view for quick testing purposes or if your usage of the platform view is very simple.
/// For more complex implementations, implement ``PlatformViewRepresentable`` instead.
public struct PlatformViewWrapper<PlatformViewType: PlatformView>: PlatformViewRepresentable {

    /// The type of closure used to create a platform-native view for wrapping in a SwiftUI view.
    /// - Parameters:
    ///   - context: The SwiftUI context that can be used to read values from the environment when creating your view.
    public typealias MakeViewBlock = @MainActor (_ context: Context) -> PlatformViewType

    /// The type of closure used to update a platform-native view during SwiftUI view updates.
    /// - Parameters:
    ///   - view: The platform-native view. You may read and write properties or call methods to update the view based on the SwiftUI context.
    ///   - context: The SwiftUI context that can be used to read values from the environment when creating your view.
    public typealias UpdateViewBlock = @MainActor (_ view: PlatformViewType, _ context: Context) -> ()
    
    /// The closure used to create the platform view.
    public var make: MakeViewBlock

    /// The closure used to update the platform view with SwiftUI updates.
    public var update: UpdateViewBlock
    
    /// Wrap a platform-native view in a SwiftUI view with custom creation and update blocks.
    /// - Parameters:
    ///   - make: The block called when SwiftUI requests the view to be created.
    ///   - update: The block called when SwiftUI requests the view to be updated.
    public init(make: @escaping MakeViewBlock, update: UpdateViewBlock? = nil) {
        self.make = make
        self.update = update ?? { _, _ in }
    }

    /// Wrap a platform-native view in a SwiftUI view with custom creation and update blocks.
    /// - Parameters:
    ///   - make: The block called when SwiftUI requests the view to be created.
    ///   - update: The block called when SwiftUI requests the view to be updated.
    ///
    /// Use this initializer if you don't care about the `context` argument when creating your view.
    @_disfavoredOverload
    public init(make: @escaping @MainActor () -> PlatformViewType, update: UpdateViewBlock? = nil) {
        self.init(make: { _ in make() }, update: update)
    }

    public func makePlatformView(context: Context) -> PlatformViewType {
        make(context)
    }

    public func updatePlatformView(_ platformView: PlatformViewType, context: Context) {
        update(platformView, context)
    }
}

#if DEBUG

// MARK: - Previews

final class _WrappedViewTest: PlatformView {
    @Invalidating(.layout)
    var fillColor: CGColor? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }

        platformLayer.backgroundColor = fillColor
    }

    #if os(macOS)
    override func layout() {
        super.layout()

        layoutSubviews()
    }
    #endif
}

@available(iOS 17, tvOS 17, macOS 14, *)
#Preview {
    PlatformViewWrapper { context in
        _WrappedViewTest()
    } update: { view, context in
        view.fillColor = context.environment.colorScheme == .dark ? PlatformColor.systemPink.cgColor : PlatformColor.systemOrange.cgColor
    }
}

#endif
