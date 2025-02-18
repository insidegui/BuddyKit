import SwiftUI

// MARK: - UIKit Types

#if canImport(UIKit)

import UIKit

/// `UIImage/NSImage` alias for platform-agnostic code.
public typealias PlatformImage = UIImage

/// `UIColor/NSColor` alias for platform-agnostic code.
public typealias PlatformColor = UIColor

#if !os(watchOS)
    /// `UIView/NSView` alias for platform-agnostic code.
    public typealias PlatformView = UIView

    /// `UIViewController/NSViewController` alias for platform-agnostic code.
    public typealias PlatformViewController = UIViewController

    /// `UIViewControllerRepresentable/NSViewControllerRepresentable` alias for platform-agnostic code.
    public typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable

    /// `UIViewRepresentable/NSViewRepresentable` alias for platform-agnostic code.
    public typealias PlatformViewRepresentableType = UIViewRepresentable

    /// `UIWindowScene` alias for platform-agnostic code.
    /// - note: Since AppKit doesn't have the concept of window scenes, this is aliased to `NSScreen` when building a native macOS target.
    public typealias PlatformWindowScene = UIWindowScene

    #if os(visionOS)
        /// `UIScreen/NSScreen` alias for platform-agnostic code.
        /// - note: `UIScreen` is not available on visionOS. When building for visionOS, this alias resolves to a shimmed type that only includes the static `main` and the `scale` properties.
        public typealias PlatformScreen = BuddyPlatformShim_UIScreen
    #else
        /// `UIScreen/NSScreen` alias for platform-agnostic code.
        /// - note: `UIScreen` is not available on visionOS. When building for visionOS, this alias resolves to a shimmed type that only includes the static `main` and the `scale` properties.
        public typealias PlatformScreen = UIScreen
    #endif // os(xrOS)
#endif // os(watchOS)

public extension PlatformImage {
    convenience init?(contentsOf url: URL) {
        self.init(contentsOfFile: url.path)
    }
}

#endif // canImport(UIKit)

// MARK: - AppKit Types

#if os(macOS)

import AppKit

/// `UIImage/NSImage` alias for platform-agnostic code.
public typealias PlatformImage = NSImage

/// `UIColor/NSColor` alias for platform-agnostic code.
public typealias PlatformColor = NSColor

/// `UIView/NSView` alias for platform-agnostic code.
open class PlatformView: NSView { }

/// `UIViewController/NSViewController` alias for platform-agnostic code.
public typealias PlatformViewController = NSViewController

/// `UIViewControllerRepresentable/NSViewControllerRepresentable` alias for platform-agnostic code.
public typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable

/// `UIViewRepresentable/NSViewRepresentable` alias for platform-agnostic code.
/// - note: You may adopt the ``PlatformViewRepresentable`` protocol in order to use a single implementation for both UIKit and AppKit platforms.
public typealias PlatformViewRepresentableType = NSViewRepresentable

/// `UIScreen/NSScreen` alias for platform-agnostic code.
/// - note: `UIScreen` is not available on visionOS. When building for visionOS, this alias resolves to a shimmed type that only includes the static `main` and the `scale` properties.
public typealias PlatformScreen = NSScreen

/// `UIWindowScene` alias for platform-agnostic code.
/// - note: Since AppKit doesn't have the concept of window scenes, this is aliased to `NSScreen` when building a native macOS target.
public typealias PlatformWindowScene = NSScreen

public extension NSImage {
    convenience init(cgImage: CGImage) {
        self.init(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }

    func pngData() -> Data? {
        guard let tiffRepresentation else { return nil }
        return NSBitmapImageRep(data: tiffRepresentation)?.representation(using: .png, properties: [:])
    }

    var cgImage: CGImage? { self.cgImage(forProposedRect: nil, context: nil, hints: nil) }
}

#endif // os(macOS)

extension PlatformImage: @unchecked @retroactive Sendable { }
