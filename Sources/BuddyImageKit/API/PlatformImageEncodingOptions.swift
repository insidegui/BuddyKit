import Foundation

/// Represents metadata that can be encoded into an image.
/// Currently supports a small subset of the IPTC namespace.
public struct ImageMetadata: Hashable {
    public struct IPTC: Hashable {
        public var credit: String?
        public var digitalSourceType: String?

        public init(credit: String? = nil, digitalSourceType: String? = nil) {
            self.credit = credit
            self.digitalSourceType = digitalSourceType
        }
    }

    public var iptc: IPTC?

    public init(iptc: IPTC? = nil) {
        self.iptc = iptc
    }
}

/// Configures the encoding of a native image type into a common image file format such as HEIC or PNG.
/// There are static conveniences for ``default``, ``thumbnail``, as well as for starting a declaration
/// with ``maxSize(_:)-swift.type.method``, ``quality(_:)-swift.type.method``, or ``preserveColorSpace(_:)-swift.type.method``.
public struct PlatformImageEncodingOptions {
    public var lossyCompressionQuality: Float = 1.0
    public var maxSize: Double? = nil
    public var preserveColorSpace: Bool = true
    public var preserveGainMap: Bool = true
    public var metadata: ImageMetadata? = nil

    public init(lossyCompressionQuality: Float = 1.0, maxSize: Double? = nil, preserveColorSpace: Bool = true, preserveGainMap: Bool = true, metadata: ImageMetadata? = nil) {
        self.lossyCompressionQuality = lossyCompressionQuality
        self.maxSize = maxSize
        self.preserveColorSpace = preserveColorSpace
        self.preserveGainMap = preserveGainMap
        self.metadata = metadata
    }
}

extension PlatformImageEncodingOptions: Hashable { }

// MARK: - Convenience API

public extension PlatformImageEncodingOptions {
    static let defaultSharingThumbnailSize: Double = 320

    static let `default` = PlatformImageEncodingOptions()
    static let thumbnail = PlatformImageEncodingOptions(lossyCompressionQuality: 0.8, maxSize: 800)
    static let sharingThumbnail = PlatformImageEncodingOptions(lossyCompressionQuality: 0.9, maxSize: PlatformImageEncodingOptions.defaultSharingThumbnailSize)

    /// This makes it possible to declare options by starting with `.maxSize(...)` and following up with `.quality(...)`, etc.
    static func maxSize(_ maxSize: Double) -> PlatformImageEncodingOptions {
        PlatformImageEncodingOptions.default
            .maxSize(maxSize)
    }

    /// This makes it possible to declare options by starting with `.quality(...)` and following up with `.maxSize(...)`, etc.
    static func quality(_ quality: Float) -> PlatformImageEncodingOptions {
        PlatformImageEncodingOptions.default
            .quality(quality)
    }

    /// This makes it possible to declare options by starting with `.preserveColorSpace(...)` and following up with `.maxSize(...)`, etc.
    static func preserveColorSpace(_ preserve: Bool) -> PlatformImageEncodingOptions {
        PlatformImageEncodingOptions.default
            .preserveColorSpace(preserve)
    }

    /// Sets the metadata for the encoded image.
    /// - Parameter metadata: The metadata.
    /// - Returns: The encoding options with the metadata replaced by the one.
    static func metadata(_ metadata: ImageMetadata) -> PlatformImageEncodingOptions {
        PlatformImageEncodingOptions.default
            .metadata(metadata)
    }

    /// Determines the maximum dimension size of the encoded image.
    /// - Parameter maxSize: The maximum size for the largest dimension of the encoded image.
    /// - Returns: The encoding options with the ``maxSize`` property changed to the new value.
    ///
    /// ### Tip
    /// You can chain calls to ``maxSize(_:)-swift.method`` with other functions in order to compose the final encoding options.
    /// Example:
    /// ```swift
    /// let options = PlatformImageEncodingOptions
    ///     .default
    ///     .maxSize(512)
    ///     .quality(0.8)
    /// ```
    func maxSize(_ maxSize: Double) -> Self {
        var mSelf = self
        mSelf.maxSize = maxSize
        return mSelf
    }

    /// Controls the lossy compression quality for the image encoding.
    /// - Parameter quality: The lossy compression quality, typically a value between `0.0` (a lot of compression) and `1.0` (very little compression).
    /// - Returns: The encoding options with the ``lossyCompressionQuality`` property changed to the new value.
    ///
    /// ### Tip
    /// You can chain calls to ``quality(_:)-swift.method`` with other functions in order to compose the final encoding options.
    /// Example:
    /// ```swift
    /// let options = PlatformImageEncodingOptions
    ///     .default
    ///     .quality(0.8)
    ///     .maxSize(512)
    /// ```
    func quality(_ quality: Float) -> Self {
        var mSelf = self
        mSelf.lossyCompressionQuality = quality
        return mSelf
    }

    /// Controls whether the image is encoded with the same color space as the input image.
    /// - Parameter preserve: Whether the color space should be preserved.
    /// - Returns: The encoding options with the ``preserveColorSpace`` property changed to the new value.
    ///
    /// ### Tip
    /// You can chain calls to ``preserveColorSpace(_:)-swift.method`` with other functions in order to compose the final encoding options.
    /// Example:
    /// ```swift
    /// let options = PlatformImageEncodingOptions
    ///     .default
    ///     .preserveColorSpace(false)
    ///     .maxSize(512)
    /// ```
    func preserveColorSpace(_ preserve: Bool) -> Self {
        var mSelf = self
        mSelf.preserveColorSpace = preserve
        return mSelf
    }

    /// Sets the metadata for the encoded image.
    /// - Parameter metadata: The image metadata.
    /// - Returns: The encoding options with the metadata replaced by the new one.
    ///
    /// This function will replace any existing metadata in the encoding options with the new one.
    func metadata(_ metadata: ImageMetadata) -> Self {
        var mSelf = self
        mSelf.metadata = metadata
        return mSelf
    }
}
