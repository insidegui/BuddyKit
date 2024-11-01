import Foundation
import CoreGraphics
internal import ImageIO
import UniformTypeIdentifiers
import os

public extension CGImage {
    func encodedData(type: UTType, options: PlatformImageEncodingOptions) throws -> Data {
        guard let cfData = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            throw PlatformImageError("Failed to create CFMutableData")
        }
        guard let destination = CGImageDestinationCreateWithData(cfData, type.identifier as CFString, 1, nil) else {
            throw PlatformImageError("Failed to create image destination")
        }

        let optionsDict: CFDictionary = options.optionsDictionary(forEncoding: self, type: type)

        logger.debug("Options for encoding \(type.identifier, privacy: .public): \(String(describing: optionsDict))")

        CGImageDestinationAddImage(destination, self, optionsDict)
        CGImageDestinationFinalize(destination)

        return cfData as Data
    }

    func encode(_ type: UTType, to url: URL, options: PlatformImageEncodingOptions, addExtensionIfNeeded: Bool) throws -> URL {
        let effectiveURL: URL

        if addExtensionIfNeeded {
            var fileExtension = UTType(type.identifier)?.preferredFilenameExtension ?? url.pathExtension

            /// Stupid UTI uses `jpeg`, we want `jpg`...
            if fileExtension.caseInsensitiveCompare("jpeg") == .orderedSame {
                fileExtension = "jpg"
            }

            if url.pathExtension.caseInsensitiveCompare(fileExtension) != .orderedSame {
                effectiveURL = url
                    .deletingPathExtension()
                    .appendingPathExtension(fileExtension)
            } else {
                effectiveURL = url
            }
        } else {
            effectiveURL = url
        }

        guard let destination = CGImageDestinationCreateWithURL(effectiveURL as CFURL, type.identifier as CFString, 1, nil) else {
            throw PlatformImageError("Failed to create image destination")
        }

        let optionsDict: CFDictionary = options.optionsDictionary(forEncoding: self, type: type)

        logger.debug("Options for encoding \(type.identifier, privacy: .public): \(String(describing: optionsDict))")

        CGImageDestinationAddImage(destination, self, optionsDict)
        try CGImageDestinationFinalize(destination)
            .require("Error finalizing image destination.")

        return effectiveURL
    }
}
