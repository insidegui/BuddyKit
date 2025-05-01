import Foundation

/// A platform-agnostic pasteboard for simple operations such as copying a string to the pasteboard.
/// Wraps `NSPasteboard` on macOS and `UIPasteboard` on iOS and variants.
@available(iOS 15.0, macOS 12.0, visionOS 1.0, *)
@available(watchOS, unavailable, message: "There's no pasteboard on watchOS.")
@available(tvOS, unavailable, message: "There's no pasteboard on tvOS.")
public final class Pasteboard: Sendable {
    public static let general = Pasteboard()

    private init() { }

    public var string: String? {
        get { _string }
        set { _string = newValue }
    }
}

#if canImport(UIKit) && !os(watchOS) && !os(tvOS)

import UIKit

private extension Pasteboard {
    var _string: String? {
        get { UIPasteboard.general.string }
        set { UIPasteboard.general.string = newValue }
    }
}

#elseif canImport(AppKit)

import AppKit

private extension Pasteboard {
    var _string: String? {
        get { NSPasteboard.general.string(forType: .string) }
        set {
            NSPasteboard.general.clearContents()
            if let newValue {
                NSPasteboard.general.setString(newValue, forType: .string)
            }
        }
    }
}

#else

@available(iOS 15.0, macOS 12.0, visionOS 1.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
private extension Pasteboard {
    var _string: String? {
        get { nil }
        set { _ = newValue }
    }
}

#endif
