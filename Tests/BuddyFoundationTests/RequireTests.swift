import Foundation
import Testing
@testable import BuddyFoundation

private struct TestError: Error { }

@Suite
struct RequireTests {
    @Test func testBoolRequireTrue() throws {
        #expect(throws: TestError.self) {
            try false.require(TestError())
            try false.requireTrue(TestError())
        }

        #expect(try true.require(TestError()))
        #expect(try true.requireTrue(TestError()))
    }

    @Test func testBoolRequireFalse() throws {
        #expect(throws: TestError.self) {
            try true.requireFalse(TestError())
        }

        #expect(try false.requireFalse(TestError()))
    }

    @Test func testOptionalBoolRequireTrue() throws {
        #expect(throws: TestError.self) {
            try Optional<Bool>.some(false).requireTrue(TestError())
        }

        #expect(try Optional<Bool>.some(true).requireTrue(TestError()))
    }

    @Test func testOptionalBoolRequireFalse() throws {
        #expect(throws: TestError.self) {
            try Optional<Bool>.some(true).requireFalse(TestError())
        }

        #expect(try Optional<Bool>.some(false).requireFalse(TestError()))
    }

    @Test func testOptionalRequire() throws {
        #expect(throws: TestError.self) {
            let string: String? = nil
            try string.require(TestError())
        }

        let string: String? = "Hello"
        #expect(try string.require(TestError()) == "Hello")
    }

    @Test func testCollectionRequireNotEmpty() throws {
        #expect(throws: TestError.self) {
            try Array<String>().requireNotEmpty(TestError())
        }

        let array: [String] = ["Hello"]
        #expect(try array.requireNotEmpty(TestError()) == ["Hello"])
    }

    @Test func testCollectionRequireEmpty() throws {
        #expect(throws: TestError.self) {
            let array: [String] = ["Hello"]
            try array.requireEmpty(TestError())
        }

        #expect(try Array<String>().requireEmpty(TestError()) == [])
    }

    @Test func testCastRequire() throws {
        let erasedValue: Any? = "Hello"

        #expect(throws: TestError.self) {
            let _: Int = try cast(erasedValue, error: TestError())
        }

        #expect(try cast(erasedValue, error: TestError()) == "Hello")
    }
}
