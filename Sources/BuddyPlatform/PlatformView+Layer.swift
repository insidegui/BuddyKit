#if !os(watchOS)
import SwiftUI

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

    open override func layout() {
        layoutSubviews()
    }

    /// This offers a place to override `layoutSubviews` for both UIKit and AppKit, since the method name on `NSView` is just `layout`.
    open func layoutSubviews() {
        super.layout()
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

#if DEBUG
private final class TestView: PlatformView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let testLayer: CALayer

        if let layer = platformLayer.sublayers?.first {
            testLayer = layer
        } else {
            testLayer = CALayer()
            testLayer.backgroundColor = PlatformColor.systemGreen.cgColor
            platformLayer.addSublayer(testLayer)
        }


        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0)

        testLayer.bounds = CGRect(
            x: 0,
            y: 0,
            width: platformLayer.bounds.width * 0.5,
            height: platformLayer.bounds.height * 0.5
        )
        testLayer.position = CGPoint(
            x: platformLayer.frame.midX,
            y: platformLayer.frame.midY
        )

        platformLayer.backgroundColor = PlatformColor.systemBlue.cgColor

        CATransaction.commit()

        print(#function, bounds, "testLayer:", testLayer.bounds)
    }
}

@available(macOS 15.0, iOS 18.0, *)
#Preview {
    TestView(frame: .init(x: 0, y: 0, width: 200, height: 200))
}
#endif
