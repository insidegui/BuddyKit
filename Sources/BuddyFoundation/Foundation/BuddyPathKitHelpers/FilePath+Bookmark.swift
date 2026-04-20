import Foundation
import BuddyPathKit

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension FilePath {
    func bookmarkData(options: URL.BookmarkCreationOptions = [.minimalBookmark], includingResourceValuesForKeys keys: Set<URLResourceKey>? = [.fileIdentifierKey]) throws -> Data {
        try url.bookmarkData(options: options, includingResourceValuesForKeys: keys, relativeTo: nil)
    }

    init(bookmarkData: Data, options: URL.BookmarkResolutionOptions = [.withoutUI]) throws {
        var ignored = false
        try self.init(bookmarkData: bookmarkData, options: options, isStale: &ignored)
    }

    init(bookmarkData: Data, options: URL.BookmarkResolutionOptions = [.withoutUI], isStale: inout Bool) throws {
        let url = try URL(resolvingBookmarkData: bookmarkData, options: options, relativeTo: nil, bookmarkDataIsStale: &isStale)
            /// Resolving from bookmark often results in symlinks not being resolved (ex `/var/...` rather than `/private/var/...`)
            .resolvingSymlinksInPath()

        self.init(url)
    }
}
