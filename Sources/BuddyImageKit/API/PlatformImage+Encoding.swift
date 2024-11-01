import Foundation
import UniformTypeIdentifiers
import os

public extension PlatformImage {
    func encodedData(type: UTType, options: PlatformImageEncodingOptions = .default) throws -> Data {
        guard let cgImage = self.cgImage else {
            throw PlatformImageError("Failed to create a CGImage")
        }
        return try cgImage.encodedData(type: type, options: options)
    }

    @discardableResult
    func encode(_ type: UTType, to url: URL, options: PlatformImageEncodingOptions = .default, addExtensionIfNeeded: Bool = false) throws -> URL {
        guard let cgImage = self.cgImage else {
            throw PlatformImageError("Failed to create a CGImage")
        }
        return try cgImage.encode(type, to: url, options: options, addExtensionIfNeeded: addExtensionIfNeeded)
    }

    func converted(to type: UTType, options: PlatformImageEncodingOptions = .default) throws -> PlatformImage {
        try PlatformImage(data: encodedData(type: type, options: options))
            .require("Failed to read \(type.identifier) image.")
    }

    @discardableResult
    func createThumbnail(
        at url: URL,
        type: UTType = .heic,
        quality: Float = PlatformImageEncodingOptions.thumbnail.lossyCompressionQuality,
        maxSize: Double = PlatformImageEncodingOptions.thumbnail.maxSize ?? 1024,
        addExtensionIfNeeded: Bool = false
    ) throws -> PlatformImage {
        var options: PlatformImageEncodingOptions = .thumbnail
        options.lossyCompressionQuality = quality
        options.maxSize = maxSize

        try encode(type, to: url, options: options, addExtensionIfNeeded: addExtensionIfNeeded)

        guard let thumbnailImage = PlatformImage(contentsOf: url) else {
            throw PlatformImageError("Failed to load generated thumbnail.")
        }

        return thumbnailImage
    }

}
