import SwiftUI

/// Generic wrapper for a platform view controller to be embedded in a SwiftUI view hierarchy.
///
/// This view can be used to wrap any `UIViewController` in UIKit or any `NSViewController` in AppKit for inclusion in a SwiftUI view hierarchy.
///
/// > Tip: Use this type to embed a platform-native view controller for quick testing purposes or if your usage of the platform view controller is very simple.
/// For more complex implementations, implement ``PlatformViewControllerRepresentable`` instead.
public struct PlatformViewControllerWrapper<PlatformViewControllerType: PlatformViewController>: PlatformViewControllerRepresentable {

    /// The type of closure used to create a platform-native view controller for wrapping in a SwiftUI view.
    /// - Parameters:
    ///   - context: The SwiftUI context that can be used to read values from the environment when creating your view controller.
    public typealias MakeViewControllerBlock = @MainActor (_ context: Context) -> PlatformViewControllerType

    /// The type of closure used to update a platform-native view controller during SwiftUI view updates.
    /// - Parameters:
    ///   - viewController: The platform-native view controller. You may read and write properties or call methods to update the view based on the SwiftUI context.
    ///   - context: The SwiftUI context that can be used to read values from the environment when creating your view controller.
    public typealias UpdateViewControllerBlock = @MainActor (_ viewController: PlatformViewControllerType, _ context: Context) -> ()

    /// The closure used to create the platform view controller.
    public var make: MakeViewControllerBlock

    /// The closure used to update the platform view controller with SwiftUI updates.
    public var update: UpdateViewControllerBlock
    
    /// Wrap a platform-native view controller in a SwiftUI view with custom creation and update blocks.
    /// - Parameters:
    ///   - make: The block called when SwiftUI requests the view controller to be created.
    ///   - update: The block called when SwiftUI requests the view controller to be updated.
    public init(make: @escaping MakeViewControllerBlock, update: UpdateViewControllerBlock? = nil) {
        self.make = make
        self.update = update ?? { _, _ in }
    }

    /// Wrap a platform-native view controller in a SwiftUI view with custom creation and update blocks.
    /// - Parameters:
    ///   - make: The block called when SwiftUI requests the view controller to be created.
    ///   - update: The block called when SwiftUI requests the view controller to be updated.
    ///
    /// Use this initializer if you don't care about the `context` argument when creating your view controller.
    @_disfavoredOverload
    public init(make: @escaping @MainActor () -> PlatformViewControllerType, update: UpdateViewControllerBlock? = nil) {
        self.init(make: { _ in make() }, update: update)
    }

    public func makePlatformViewController(context: Context) -> PlatformViewControllerType {
        make(context)
    }

    public func updatePlatformViewController(_ platformViewController: PlatformViewControllerType, context: Context) {
        update(platformViewController, context)
    }
}

#if DEBUG

// MARK: - Previews

final class _WrappedViewControllerTest: PlatformViewController {
    var fillColor: CGColor? = nil {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            defer { CATransaction.commit() }

            view.platformLayer.backgroundColor = fillColor
        }
    }

    override func loadView() {
        view = PlatformView()
    }
}

@available(iOS 17, tvOS 17, macOS 14, *)
#Preview {
    PlatformViewControllerWrapper { context in
        _WrappedViewControllerTest()
    } update: { controller, context in
        controller.fillColor = context.environment.colorScheme == .dark ? PlatformColor.systemPink.cgColor : PlatformColor.systemOrange.cgColor
    }
}

#endif
