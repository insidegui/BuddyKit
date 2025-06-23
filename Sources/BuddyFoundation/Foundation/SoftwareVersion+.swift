import Foundation

public extension ProcessInfo {
    /// The current operating system version as a ``SoftwareVersion``.
    var osSoftwareVersion: SoftwareVersion { .currentOS }
}

public extension Bundle {
    /// The current bundle version as indicated by its `CFBundleShortVersionString` Info.plist value.
    ///
    /// This reads the value from `CFBundleShortVersionString` and parses it into a ``SoftwareVersion``.
    /// - note: This property causes  an assertion failure in debug builds if `CFBundleShortVersionString` is missing or contains an invalid version string.
    var softwareVersion: SoftwareVersion {
        do {
            let versionString: String = try self[info: "CFBundleShortVersionString"]
                .require("Bundle for \(bestEffortName) is missing CFBundleShortVersionString.")

            return try SoftwareVersion(string: versionString)
                .require("Bundle for \(bestEffortName) has invalid CFBundleShortVersionString: \"\(versionString)\".")
        } catch {
            assertionFailure("\(error)")
            return .empty
        }
    }
}

public extension SoftwareVersion {
    /// The current operating system version.
    static let currentOS = SoftwareVersion(
        major: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
        minor: ProcessInfo.processInfo.operatingSystemVersion.minorVersion,
        patch: ProcessInfo.processInfo.operatingSystemVersion.patchVersion
    )

    /// The current app version.
    ///
    /// This reads the value from `CFBundleShortVersionString` on `Bundle.main` and parses it into a ``SoftwareVersion``.
    /// - note: This property causes  an assertion failure in debug builds if `CFBundleShortVersionString` is missing or contains an invalid version string.
    static let currentApp = Bundle.main.softwareVersion
}
