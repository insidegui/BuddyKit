import Foundation
internal import ImageIO

internal extension ImageMetadata {
    func apply(to dictionary: inout [CFString: Any]) {
        guard let metaDictionary = createDictionary() else { return }

        dictionary.merge(metaDictionary, uniquingKeysWith: { _, b in b })
    }

    func createDictionary() -> [CFString: Any]? {
        var output = [CFString: Any]()

        if let iptc, let iptcDict = iptc.createDictionary() {
            output[kCGImagePropertyIPTCDictionary] = iptcDict
        }

        return output.nilWhenEmpty()
    }
}

internal extension ImageMetadata.IPTC {
    func createDictionary() -> [CFString: Any]? {
        var output = [CFString: Any]()

        if let credit {
            output[kCGImagePropertyIPTCCredit] = credit
        }
        if let digitalSourceType {
            output[kCGImagePropertyIPTCExtDigitalSourceType] = digitalSourceType
        }

        return output.nilWhenEmpty()
    }
}

private extension Collection {
    func nilWhenEmpty() -> Self? {
        guard !isEmpty else { return nil }
        return self
    }
}
