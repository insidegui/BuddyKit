import Foundation
import Testing
@testable import BuddyFoundation

@Suite("Prefix/Suffix Tests")
struct PrefixSuffixTests {
    @Test func testRemovingPrefix() {
        #expect("Hello_World".removingPrefix("Hello_") == "World")
    }

    @Test func testRemovingPrefixNotFound() {
        #expect("Hello_World".removingPrefix("Apple") == "Hello_World")
    }

    @Test func testRemovingPrefixLongerThanString() {
        #expect("Hello_World".removingPrefix("A_String_Longer_Than_The_Other_One") == "Hello_World")
    }

    @Test func testRemovingSuffix() {
        #expect("Hello_World".removingSuffix("_World") == "Hello")
    }

    @Test func testRemovingSuffixNotFound() {
        #expect("Hello_World".removingSuffix("Apple") == "Hello_World")
    }

    @Test func testRemovingSuffixLongerThanString() {
        #expect("Hello_World".removingSuffix("A_String_Longer_Than_The_Other_One") == "Hello_World")
    }

    @Test func testUppercasingFirst() {
        #expect("hello World".uppercasingFirstCharacter() == "Hello World")
    }

    @Test func testLowercasingFirst() {
        #expect("Hello world".lowercasingFirstCharacter() == "hello world")
    }

    @Test func testUppercasingFirstSingleCharacter() {
        #expect("h".uppercasingFirstCharacter() == "H")
    }

    @Test func testLowercasingFirstSingleCharacter() {
        #expect("H".lowercasingFirstCharacter() == "h")
    }

    @Test func testUppercasingFirstEmpty() {
        #expect("".uppercasingFirstCharacter() == "")
    }

    @Test func testLowercasingFirstEmpty() {
        #expect("".lowercasingFirstCharacter() == "")
    }
}
