#if os(macOS)
import Foundation
import AppKit

public extension URL {

    /// Selects the file at the specified URL in Finder.
    func revealInFinder() {
        NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: deletingLastPathComponent().path)
    }
}
#endif // os(macOS)
