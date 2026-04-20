import Foundation
import Testing
@testable import BuddyFoundation

@Suite
struct FilePathBookmarkTests {
    @Test func testCreateBookmark() throws {
        let file = FilePath.temporary + UUID().uuidString
        try file.write("test")
        defer { try? file.delete() }

        let bookmark = try file.bookmarkData()

        var stale = false
        let fromBookmark = try FilePath(bookmarkData: bookmark, isStale: &stale)

        #expect(fromBookmark.string == file.string)
        #expect(stale == false)
    }

    @Test func testResolveBookmarkRenamedFile() throws {
        let file = FilePath.temporary + UUID().uuidString
        try file.write("test")
        defer { try? file.delete() }

        let bookmark = try file.bookmarkData()

        let renamedFile = FilePath.temporary + UUID().uuidString
        try file.move(renamedFile)

        defer { try? renamedFile.delete() }

        var stale = false
        let fromBookmark = try FilePath(bookmarkData: bookmark, isStale: &stale)

        #expect(fromBookmark.isFile)

        let contents: String = try fromBookmark.read()

        #expect(contents == "test")
        #expect(stale == true)
    }
}
