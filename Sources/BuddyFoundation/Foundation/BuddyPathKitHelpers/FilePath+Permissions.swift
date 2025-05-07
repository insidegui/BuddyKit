import Foundation
import BuddyPathKit

public extension FilePath {
    /// Equivalent to `chmod <mode> ...`.
    func chmod(_ mode: UInt16) throws {
        let attributes: [FileAttributeKey: Any] = [
            .posixPermissions: NSNumber(value: mode)
        ]
        try FileManager.default.setAttributes(attributes, ofItemAtPath: string)
    }

    /// Equivalent to `chmod -R <mode> ...`.
    /// - Parameters:
    ///   - mode: The permission mode to apply.
    ///   - failureMode: Whether to fail or continue of one or more items fail to have their mode changed.
    func chmodRecursive(_ mode: UInt16, failureMode: FailureMode = .open) throws {
        let enumerator = try FileManager.default.enumerator(atPath: string)
            .require("chmod: Failed to enumerate files at \(string.quoted).")

        let strings: [String] = ([string] + enumerator.compactMap { $0 as? String }.map { "\(string)/\($0)" })
        let paths: [FilePath] = strings.map { FilePath($0) }

        for item in paths {
            do {
                try item.chmod(mode)
            } catch {
                switch failureMode {
                case .open:
                    fputs("WARN: chmod: Failed to change permission for \(item.description.quoted). \(error)\n", stderr)
                    continue
                case .closed:
                    throw error
                }
            }
        }
    }
}
