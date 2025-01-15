#if !os(watchOS)

#if os(macOS)
import AppKit

@objc extension PlatformView {
    /// Platform-agnostic view layer property.
    ///
    /// On UIKit, this property just returns the `layer` property.
    ///
    /// On AppKit, this property sets `wantsLayer` to `true`, ensures the view has gotten a layer, and returns the unwrapped `layer` property.
    /// This addresses the different optionality/settability of the `layer` property between `UIView` and `NSView`.
    open var platformLayer: CALayer {
        if !wantsLayer {
            wantsLayer = true
        }

        if layer == nil {
            layer = CALayer()
        }

        guard let layer else {
            assertionFailure("Unexpected: NSView layer is nil right after creating the layer")
            return CALayer() // fallback in the extremely unlikely event that the above assertion fails in production
        }

        return layer
    }
    
    /// The platform window scene hosting this view.
    /// - note: Check out ``PlatformWindowScene`` for details on how this behaves in AppKit.
    open var hostingWindowScene: PlatformWindowScene? { window?.screen }

    /// This offers a place to override `layoutSubviews` for both UIKit and AppKit, since the method name on `NSView` is just `layout`.
    open func layoutSubviews() {
        layout()
    }

    /// This offers a place to override `didMoveToSuperview` for both UIKit and AppKit, since the method name on `NSView` is different.
    /// - note: Be sure to call `viewDidMoveToSuperview` (inside an `#if os(macOS)/#endif` block) when implementing this on `NSView` if you'd like to inherit superclass behavior.
    open func didMoveToSuperview() {
        viewDidMoveToSuperview()
    }

    /// This offers a place to override `didMoveToWindow` for both UIKit and AppKit, since the method name on `NSView` is different.
    /// - note: Be sure to call `viewDidMoveToWindow` (inside an `#if os(macOS)/#endif` block) when implementing this on `NSView` if you'd like to inherit superclass behavior.
    open func didMoveToWindow() {
        viewDidMoveToWindow()
    }
}
#else
import UIKit

@objc extension PlatformView {
    /// Platform-agnostic view layer property.
    ///
    /// On UIKit, this property just returns the `layer` property.
    ///
    /// On AppKit, this property sets `wantsLayer` to `true`, ensures the view has gotten a layer, and returns the unwrapped `layer` property.
    /// This addresses the different optionality/settability of the `layer` property between `UIView` and `NSView`.
    open var platformLayer: CALayer { layer }

    /// Whether the view wants to have a backing `CALayer`.
    ///
    /// - note: This property is a no-op on UIKit, but having this shim allows `wantsLayer`
    /// to be accessed without the need for compile-time checks.
    open var wantsLayer: Bool {
        get { true }
        set { }
    }

    /// The platform window scene hosting this view.
    /// - note: Check out ``PlatformWindowScene`` for details on how this behaves in AppKit.
    open var hostingWindowScene: PlatformWindowScene? { window?.windowScene }
}
#endif // os(macOS)

#endif // !os(watchOS)
