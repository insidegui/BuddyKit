#if os(macOS)
import Foundation
import SwiftData
import AppKit

@available(macOS 14, *)
@MainActor
public extension ModelContainer {
    /// Opens an inspectable copy of the database with the default app for `.db` files.
    func openDatabaseCopyWithFinder() {
        do {
            let copyURL = try createInspectableDatabaseCopy()

            /// First attempt to open the database, if there's no app that can open it, just reveal in Finder.
            if !NSWorkspace.shared.open(copyURL) {
                copyURL.revealInFinder()
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    /// Reveals the database file in Finder.
    func revealDatabaseInFinder() {
        do {
            guard let config = configurations.first(where: { !$0.isStoredInMemoryOnly }) else {
                throw "Couldn't find any exportable configuration."
            }

            config.url.revealInFinder()
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}

private extension URL {
    /// This extension exists in BuddyAppKit, but I wanted to keep this module dependant on BuddyFoundation only,
    /// and didn't want to include AppKit code in BuddyFoundation, so here we are...
    func revealInFinder() {
        NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: deletingLastPathComponent().path)
    }
}
#endif // os(macOS)
