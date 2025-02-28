import Foundation
import OSLog

/// Verbose logging for UI-related code.
/// - Parameters:
///   - message: The content to be logged.
///   - file: Leave as default.
///   - line: Leave as default.
///
/// This function is designed to be used in user interface code for logging verbose UI-related events that should
/// not be logged in release builds, or even in every session of a debug build.
///
/// When running in a SwiftUI preview, the message is logged using `print()` so that it shows up in Xcode's previews console.
/// When running the app normally, the message is logged using `Logger` so that it can be filtered in Xcode's console or in the Console app.
///
/// **Messages are only logged in SwiftUI previews or if the `VerboseUILoggingEnabled` user defaults key is set to `true`.**
///
/// To allow logging when running from Xcode, you can add "-VerboseUILoggingEnabled YES" as one of the "Arguments Passed On Launch" in your app's scheme settings.
///
/// - note: This function has no performance impact in release builds because its first argument is an autoclosure and its inlined implementation is compiled out when the `DEBUG` flag is set,
/// ensuring that the logged message/content is never evaluated in release builds.
@inlinable
@inline(__always)
public func UILog(_ message: @autoclosure () -> Any?, _ file: StaticString = #filePath, _ line: Int = #line) {
    #if DEBUG
    guard Logger.uiLogEnabled else { return }

    let content: String
    if let value = message() {
        content = String(describing: value)
    } else {
        content = "<nil>"
    }

    let prefix = URL(fileURLWithPath: "\(file)").deletingPathExtension().lastPathComponent

    /// Not using `isSwiftUIPreview` here because it can't be inlined due to the import being internal.
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        print("💅🏻 [\(prefix):\(line)] \(content)")
    } else {
        Logger.ui.notice("💅🏻 [\(prefix, privacy: .public):\(line, privacy: .public)] \(content, privacy: .public)")
    }
    #endif
}

#if DEBUG
public extension Logger {
    static let uiLogEnabled: Bool = UserDefaults.standard.bool(forKey: "VerboseUILoggingEnabled") || ProcessInfo.isSwiftUIPreview
    static let ui = Logger(subsystem: "codes.rambo.BuddyUI.Logger", category: "UILog")
}
#endif
