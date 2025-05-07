import Foundation
import BuddyPathKit
import UniformTypeIdentifiers

public extension FilePath {
    /// `true` if this path is an existing directory and the directory has no files nor subdirectories.
    var isEmptyDirectory: Bool {
        guard isDirectory else { return false }
        guard let children = try? children() else { return false }
        return children.filter {
            $0.lastComponent != ".DS_Store"
            && $0 != "."
            && $0 != ".."
        }
        .isEmpty
    }

    /// Loads file contents using the `.mappedIfSafe` option.
    func mappedIfSafe() throws -> Data { try Data(contentsOf: url, options: .mappedIfSafe) }

    /// The file's uniform type identifier if available.
    var contentType: UTType? { (try? url.resourceValues(forKeys: [.contentTypeKey]))?.contentType }

    /// The value for `fileSizeKey` in URL resource values.
    var fileSize: Int? { (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize }
}
