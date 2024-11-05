import Foundation
internal import ImageIO
import UniformTypeIdentifiers
import os

@_exported import BuddyFoundation
@_exported import BuddyPlatform

// MARK: - Options Extensions

internal extension PlatformImageEncodingOptions {
    static let supportedTypes: Set<UTType> = [.heic, .png, .jpeg]
    static let lossyTypes: Set<UTType> = [.heic, .jpeg]

    func optionsDictionary(forEncoding image: CGImage, type: UTType) -> CFDictionary {
        assert(Self.supportedTypes.contains(type), "Unsupported image type \"\(type.identifier)\".")

        var dict: [CFString: Any] = [:]

        if let maxSize {
            dict[kCGImageDestinationImageMaxPixelSize] = maxSize
        }

        /// Only include lossy compression for JPG/HEIC as PNG doesn't support lossy compression.
        if Self.lossyTypes.contains(type) {
            dict[kCGImageDestinationLossyCompressionQuality] = lossyCompressionQuality
        }

        dict[kCGImageDestinationPreserveGainMap] = preserveGainMap

        if preserveColorSpace {
            dict[kCGImagePropertyDepth] = image.bitsPerComponent
            dict[kCGImagePropertyColorModel] = kCGImagePropertyColorModelRGB
            dict[kCGImagePropertyProfileName] = "Display P3"

            if type == .heic {
                dict[kCGImagePropertyHEICSDictionary] = [
                    kCGImagePropertyHEICSCanvasPixelWidth: image.width,
                    kCGImagePropertyHEICSCanvasPixelHeight: image.height
                ]
            }
        }

        if let metadata {
            metadata.apply(to: &dict)
        }

        return dict as CFDictionary
    }
}
