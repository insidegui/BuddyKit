import Foundation
import Testing
@testable import BuddyFoundation

@Suite("Disambiguate Sequentially Tests")
struct DisambiguateSequentiallyTests {
    @Test func unambiguousStringReturnedUnmodified() {
        let siblings: [String] = ["file", "file1", "file2", "file3"]

        let target = "file6"

        let result = target.disambiguatedSequentially(with: siblings)

        #expect(result == target)
    }

    @Test func unambiguousStringReturnedUnmodifiedCaseSensitive() {
        let siblings: [String] = ["file", "file1", "file2", "file3", "File6"]

        let target = "file6"

        let result = target.disambiguatedSequentially(with: siblings, caseSensitive: true)

        #expect(result == target)
    }

    @Test func disambiguateSingleSiblingNoSuffix() {
        let siblings: [String] = ["file"]

        let result = "file".disambiguatedSequentially(with: siblings)

        #expect(result == "file1")
    }

    @Test func disambiguateSingleSiblingWithSuffix() {
        let siblings: [String] = ["file1"]

        let result = "file1".disambiguatedSequentially(with: siblings)

        #expect(result == "file2")
    }

    @Test func disambiguateSuffixWithoutSpace() {
        let siblings: [String] = ["file", "file1"]

        let result = "file".disambiguatedSequentially(with: siblings)

        #expect(result == "file2")
    }

    @Test func disambiguateSuffixWithSpace() {
        let siblings: [String] = ["file", "file 1", "file 2", "file 3"]

        let result = "file 3".disambiguatedSequentially(with: siblings)

        #expect(result == "file 4")
    }

    @Test func disambiguateSingleSiblingCustomSeparator() {
        let siblings: [String] = ["file"]

        let result = "file".disambiguatedSequentially(with: siblings, separator: "_")

        #expect(result == "file_1")
    }

    @Test func unambiguousCustomSeparator() {
        let siblings: [String] = ["file_1", "file_2", "file_3"]

        let result = "file".disambiguatedSequentially(with: siblings, separator: "_")

        #expect(result == "file")
    }

    @Test func disambiguateCustomSeparator() {
        let siblings: [String] = ["file_1", "file_2", "file_3"]

        let result = "file_2".disambiguatedSequentially(with: siblings, separator: "_")

        #expect(result == "file_4")
    }

    @Test func disambiguateComplex() {
        let siblings: [String] = ["A BC __ )_ 13", "A BC __ )_ 99", "CD X 123"]

        let result = "A BC __ )_ 99".disambiguatedSequentially(with: siblings)

        #expect(result == "A BC __ )_ 100")
    }
}
