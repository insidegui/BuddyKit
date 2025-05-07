import Foundation
import BuddyPathKit
import UniformTypeIdentifiers

public extension FilePath {
    static let bundleExtensions: Set<String> = [
        "app", "bundle", "appex", "framework"
    ]

    var isBundle: Bool {
        guard isDirectory else { return false }

        if let ext = self.extension, Self.bundleExtensions.contains(ext.lowercased()) {
            return true
        } else {
            guard let contentType = (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType else {
                return false
            }
            return contentType.conforms(to: .bundle)
                || contentType.conforms(to: .framework)
                || contentType.conforms(to: .applicationBundle)
                || contentType.conforms(to: .applicationExtension)
        }
    }

    var isAppBundle: Bool { isBundle && self.extension == "app" }

    func executablePath() -> FilePath? {
        guard let bundle = Bundle(path: string) else { return nil }
        return bundle.executableURL.flatMap { FilePath($0) }
    }

    func bundleVersionInfo() -> (version: String, build: String)? {
        guard let bundle = Bundle(path: string) else { return nil }
        guard let version: String = bundle.infoPlistValue(for: "CFBundleShortVersionString"),
              let build: String = bundle.infoPlistValue(for: "CFBundleVersion")
        else { return nil }
        return (version, build)
    }

    func bundleIdentifier() -> String? { Bundle(path: string)?.bundleIdentifier }
}
