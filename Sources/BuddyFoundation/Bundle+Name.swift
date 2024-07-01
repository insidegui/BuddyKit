import Foundation

public extension Bundle {
    /// Returns a best-effort attempt at deriving a displayable name for the bundle.
    ///
    /// This uses the bundle's display name, name, or last path component without extension as a last resort.
    /// It can be used for example when there's a need to detect the name of the app and use it in UI or as file names.
    var bestEffortName: String {
        self[info: "CFBundleDisplayName"]
        ?? self[info: "CFBundleName"]
        ?? bundleURL.deletingPathExtension().lastPathComponent
    }
}
