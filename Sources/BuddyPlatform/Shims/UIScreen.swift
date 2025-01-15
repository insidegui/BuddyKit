#if os(visionOS)
import UIKit

/// A shim for `UIScreen` on visionOS so that UIKit code that accesses `UIScreen` (via ``PlatformScreen``) can still be built.
/// - warning: Even though your visionOS code will build when using ``PlatformScreen`` on visionOS, you should move away from acessing the screen directly as that's not supported on the platform.
@MainActor
@objcMembers
open class BuddyPlatformShim_UIScreen : NSObject, UITraitEnvironment {
    private static let _main = BuddyPlatformShim_UIScreen()

    private override init() {
        super.init()
    }

    @objc(mainScreen)
    @available(*, deprecated, message: "This is shimmed by BuddyPlatform on visionOS, you should stop using UIScreen directly in your UIKit code.")
    open class var main: BuddyPlatformShim_UIScreen { _main }

    @available(*, deprecated, message: "This is shimmed by BuddyPlatform on visionOS, you should stop using UIScreen directly in your UIKit code.")
    open var scale: CGFloat { traitCollection.displayScale }

    public var traitCollection: UITraitCollection { UITraitCollection(displayScale: 2.0) }

    public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) { }
}
#endif // os(visionOS)
