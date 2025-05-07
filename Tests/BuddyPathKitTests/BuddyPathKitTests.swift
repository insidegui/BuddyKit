import XCTest
@testable import BuddyPathKit

/**
 DISCLAIMER: ChatGPT was used to convert tests from Spectre (BDD framework) into XCTest.
 */
final class BuddyPathKitTests: XCTestCase {

    var fixtures: FilePath { FilePath(#filePath).parent() + "Fixtures" }

    override func setUp() {
        super.setUp()
        let filePath = #filePath
        FilePath.current = FilePath(filePath).parent()
    }

    func testSystemSeparator() {
        XCTAssertEqual(FilePath.separator, "/")
    }

    func testCurrentWorkingDirectory() {
        XCTAssertEqual(FilePath.current.description, FileManager().currentDirectoryPath)
    }

    func testInitializationWithNoArguments() {
        XCTAssertEqual(FilePath().description, "")
    }

    func testInitializationWithString() {
        let path = FilePath("/usr/bin/swift")
        XCTAssertEqual(path.description, "/usr/bin/swift")
    }

    func testInitializationWithComponents() {
        let path = FilePath(components: ["/usr", "bin", "swift"])
        XCTAssertEqual(path.description, "/usr/bin/swift")
    }

    func testConvertibleFromStringLiteral() {
        let path: FilePath = "/usr/bin/swift"
        XCTAssertEqual(path.description, "/usr/bin/swift")
    }

    func testConvertibleToStringDescription() {
        XCTAssertEqual(FilePath("/usr/bin/swift").description, "/usr/bin/swift")
    }

    func testConvertibleToString() {
        XCTAssertEqual(FilePath("/usr/bin/swift").string, "/usr/bin/swift")
    }

    func testConvertibleToURL() {
        XCTAssertEqual(FilePath("/usr/bin/swift").url, URL(fileURLWithPath: "/usr/bin/swift"))
    }

    func testEquatable() {
        XCTAssertEqual(FilePath("/usr"), FilePath("/usr"))
        XCTAssertNotEqual(FilePath("/usr"), FilePath("/bin"))
    }

    func testHashable() {
        XCTAssertEqual(FilePath("/usr").hashValue, FilePath("/usr").hashValue)
    }

    func testRelativePath() {
        let path = FilePath("swift")
        XCTAssertEqual(path.absolute(), FilePath.current + FilePath("swift"))
        XCTAssertFalse(path.isAbsolute)
        XCTAssertTrue(path.isRelative)
    }

    func testTildePath() {
        let path = FilePath("~")
        XCTAssertEqual(path.absolute(), FilePath("/Users/") + NSUserName())
        XCTAssertFalse(path.isAbsolute)
        XCTAssertTrue(path.isRelative)
    }

    func testAbsolutePath() {
        let path = FilePath("/usr/bin/swift")
        XCTAssertEqual(path.absolute(), path)
        XCTAssertTrue(path.isAbsolute)
        XCTAssertFalse(path.isRelative)
    }

    func testNormalizePath() {
        let path = FilePath("/usr/./local/../bin/swift")
        XCTAssertEqual(path.normalize(), FilePath("/usr/bin/swift"))
    }

    func testAbbreviatePath() {
        let home = FilePath.home.string

        XCTAssertEqual(FilePath("\(home)/foo/bar").abbreviate(), FilePath("~/foo/bar"))
        XCTAssertEqual(FilePath("\(home)").abbreviate(), FilePath("~"))
        XCTAssertEqual(FilePath("\(home)/").abbreviate(), FilePath("~"))
        XCTAssertEqual(FilePath("\(home)/backups\(home)").abbreviate(), FilePath("~/backups\(home)"))
        XCTAssertEqual(FilePath("\(home)/backups\(home)/foo/bar").abbreviate(), FilePath("~/backups\(home)/foo/bar"))
        XCTAssertEqual(FilePath("\(home.uppercased())").abbreviate(), FilePath("~"))
    }

    struct FakeFSInfo: FileSystemInfo {
        let caseSensitive: Bool
        func isFSCaseSensitiveAt(path: FilePath) -> Bool {
            return caseSensitive
        }
    }

    func testAbbreviateWithCaseSensitiveFS() {
        let home = FilePath.home.string
        let fakeFSInfo = FakeFSInfo(caseSensitive: true)
        let path = FilePath("\(home.uppercased())", fileSystemInfo: fakeFSInfo)
        XCTAssertEqual(path.abbreviate().string, home.uppercased())
    }

    func testAbbreviateWithCaseInsensitiveFS() {
        let home = FilePath.home.string
        let fakeFSInfo = FakeFSInfo(caseSensitive: false)
        let path = FilePath("\(home.uppercased())", fileSystemInfo: fakeFSInfo)
        XCTAssertEqual(path.abbreviate(), FilePath("~"))
    }

    func testSymlinkWithRelativeDestination() throws {
        let path = fixtures + "symlinks/file"
        let resolvedPath = try path.symlinkDestination()
        XCTAssertEqual(resolvedPath.normalize(), fixtures + "file")
    }

    func testSymlinkWithAbsoluteDestination() throws {
        let path = fixtures + "symlinks/swift"
        let resolvedPath = try path.symlinkDestination()
        XCTAssertEqual(resolvedPath, FilePath("/usr/bin/swift"))
    }

    func testLastComponent() {
        XCTAssertEqual(FilePath("a/b/c.d").lastComponent, "c.d")
        XCTAssertEqual(FilePath("a/..").lastComponent, "..")
    }

    func testLastComponentWithoutExtension() {
        XCTAssertEqual(FilePath("a/b/c.d").lastComponentWithoutExtension, "c")
        XCTAssertEqual(FilePath("a/..").lastComponentWithoutExtension, "..")
    }

    func testComponents() {
        XCTAssertEqual(FilePath("a/b/c.d").components, ["a", "b", "c.d"])
        XCTAssertEqual(FilePath("/a/b/c.d").components, ["/", "a", "b", "c.d"])
        XCTAssertEqual(FilePath("~/a/b/c.d").components, ["~", "a", "b", "c.d"])
    }

    func testExtension() {
        XCTAssertEqual(FilePath("a/b/c.d").extension, "d")
        XCTAssertEqual(FilePath("a/b.c.d").extension, "d")
        XCTAssertNil(FilePath("a/b").extension)
    }

    func testPathExistence() {
        XCTAssertTrue(fixtures.exists)

        let path = FilePath("/pathkit/test")
        XCTAssertFalse(path.exists)
    }

    func testDirectoryCheck() {
        XCTAssertTrue((fixtures + "directory").isDirectory)
        XCTAssertTrue((fixtures + "symlinks/directory").isDirectory)
    }

    func testSymlinkCheck() {
        XCTAssertFalse((fixtures + "file/file").isSymlink)
        XCTAssertTrue((fixtures + "symlinks/file").isSymlink)
    }

    func testFileCheck() {
        XCTAssertTrue((fixtures + "file").isFile)
        XCTAssertTrue((fixtures + "symlinks/file").isFile)
    }

    func testExecutableCheck() {
        XCTAssertTrue((fixtures + "permissions/executable").isExecutable)
    }
}
