import Foundation
import Testing
@testable import BuddyFoundation
import os

struct TestPayload: Codable, Sendable {
    var value: Int
}

extension TestPayload {
    static let test = TestPayload(value: 42)
}

extension FilePath {
    static func temporaryJSON() -> FilePath {
        (FilePath.temporary + UUID().uuidString).appendingExtension("json")
    }
    static func temporaryPLIST() -> FilePath {
        (FilePath.temporary + UUID().uuidString).appendingExtension("plist")
    }
}

private let serializeTest = OSAllocatedUnfairLock(initialState: 0)

@Suite
struct CodableExtensionsTests {
    @Test func testEncodeJSONDefaultEncoder() throws {
        try serializeTest.withLock { _ in
            let value = TestPayload.test
            let file = FilePath.temporaryJSON()
            defer { try? file.delete() }
            try value.encodeJSON(to: file)
            let contents: String = try file.read()
            #expect(contents.contains("\"value\":42"))
        }
    }

    @Test func testEncodePLISTDefaultEncoder() throws {
        try serializeTest.withLock { _ in
            let value = TestPayload.test
            let file = FilePath.temporaryPLIST()
            defer { try? file.delete() }
            try value.encodePropertyList(to: file)
            let contents: Data = try file.read()
            #expect(contents.hexString == "62706C6973743030D101025576616C7565102A080B110000000000000101000000000000000300000000000000000000000000000013")
        }
    }

    @Test func testEncodeJSONCustomEncoder() throws {
        /// No need to use lock here because we're using a custom encoder.
        let value = TestPayload.test
        let file = FilePath.temporaryJSON()
        defer { try? file.delete() }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try value.encodeJSON(to: file, encoder: encoder)
        let contents: String = try file.read()
        #expect(contents == """
        {
          "value" : 42
        }
        """)
    }

    @Test func testEncodePLISTCustomEncoder() throws {
        /// No need to use lock here because we're using a custom encoder.
        let value = TestPayload.test
        let file = FilePath.temporaryPLIST()
        defer { try? file.delete() }
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        try value.encodePropertyList(to: file, encoder: encoder)
        let contents: String = try file.read()
        #expect(contents.contains("<key>value</key>"))
        #expect(contents.contains("<integer>42</integer>"))
    }

    @Test func testEncodeJSONCustomGlobalEncoder() throws {
        try serializeTest.withLock { _ in
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            JSONEncoder.default = encoder
            defer { JSONEncoder.default = JSONEncoder() }

            let value = TestPayload.test
            let file = FilePath.temporaryJSON()
            defer { try? file.delete() }
            try value.encodeJSON(to: file)
            let contents: String = try file.read()
            #expect(contents == """
            {
              "value" : 42
            }
            """)
        }
    }

    @Test func testEncodePLISTCustomGlobalEncoder() throws {
        try serializeTest.withLock { _ in
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            PropertyListEncoder.default = encoder
            defer { PropertyListEncoder.default = PropertyListEncoder() }

            let value = TestPayload.test
            let file = FilePath.temporaryPLIST()
            defer { try? file.delete() }
            try value.encodePropertyList(to: file)
            let contents: String = try file.read()
            #expect(contents.contains("<key>value</key>"))
            #expect(contents.contains("<integer>42</integer>"))
        }
    }

    @Test func testDecodeJSON() throws {
        let json = """
        {
          "value" : 42
        }
        """
        let file = FilePath.temporaryJSON()
        try file.write(json)
        defer { try? file.delete() }

        let payload = try TestPayload(jsonAt: file)

        #expect(payload.value == 42)
    }

    @Test func testDecodePLIST() throws {
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>value</key>
            <integer>42</integer>
        </dict>
        </plist>
        """
        let file = FilePath.temporaryPLIST()
        try file.write(plist)
        defer { try? file.delete() }

        let payload = try TestPayload(propertyListAt: file)

        #expect(payload.value == 42)
    }
}
