import MediaToolSwift
import AVFoundation

#if os(iOS)
import Flutter
#elseif os(OSX)
import FlutterMacOS
#endif

/// `FlutterError` extension
public extension FlutterError {
    /// Initialize `FlutterError` using `String`
    convenience init(_ message: String) {
        self.init(
            code: "CompressionError",
            message: message,
            details: nil
        )
    }
}

/// Implement JSON serialization
extension VideoInfo: Encodable {
    private enum CodingKeys: String, CodingKey {
        case path // url
        case codec // videoCodec
        case width, height // resolution
        case hasAlpha
        case isHDR
        case hasAudio
        case frameRate
        case duration
        case bitrate // videoBitrate, nullable
    }

    // Encodable conformation
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url.path, forKey: .path)
        try container.encode(videoCodec.rawValue, forKey: .codec)
        try container.encode(resolution.width, forKey: .width)
        try container.encode(resolution.height, forKey: .height)
        try container.encode(hasAlpha, forKey: .hasAlpha)
        try container.encode(isHDR, forKey: .isHDR)
        try container.encode(hasAudio, forKey: .hasAudio)
        try container.encode(frameRate, forKey: .frameRate)
        try container.encode(duration, forKey: .duration)
        try container.encode(videoBitrate, forKey: .bitrate)
    }
}

/// Implement JSON serialization
extension AudioInfo: Encodable {
    private enum CodingKeys: String, CodingKey {
        case path // url
        case codec // nullable
        case duration
        case bitrate // nullable
    }

    // Encodable conformation
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url.path, forKey: .path)
        try container.encode(codec?.rawValue, forKey: .codec)
        try container.encode(duration, forKey: .duration)
        try container.encode(bitrate, forKey: .bitrate)
    }
}

/// Implement JSON serialization
extension ImageInfo: Encodable {
    private enum CodingKeys: String, CodingKey {
        case format
        case width, height // size
        case hasAlpha
        case isHDR
        case orientation
        case isAnimated // framesCount
        case frameRate // nullable
        case duration // nullable
    }

    // Encodable conformation
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(format.rawValue, forKey: .format)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
        try container.encode(hasAlpha, forKey: .hasAlpha)
        try container.encode(isHDR, forKey: .isHDR)
        try container.encode(orientation?.rawValue ?? 1, forKey: .orientation)
        try container.encode(isAnimated, forKey: .isAnimated)
        try container.encode(frameRate, forKey: .frameRate)
        try container.encode(duration, forKey: .duration)
    }
}

/// Implement JSON deserialization
extension VideoThumbnailRequest: Decodable {
    private enum CodingKeys: String, CodingKey {
        case time
        case url
    }

    // Decodable conformation
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let time = try values.decode(Double.self, forKey: .time)
        let url = try values.decode(URL.self, forKey: .url)
        self.init(time: time, url: url)
    }
}

/// Implement JSON serialization
extension VideoThumbnailFile: Encodable {
    private enum CodingKeys: String, CodingKey {
        case url
        case format
        case width, height
        case time
    }

    // Encodable conformation
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url.path, forKey: .url)
        try container.encode(format?.rawValue, forKey: .format)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
        try container.encode(time, forKey: .time)
    }
}

/// Implement JSON deserialization
extension CompressionVideoSettings: Decodable {
    private enum CodingKeys: String, CodingKey {
        case codec
        case bitrate
        case quality
        case width, height // size
        case frameRate
        case preserveAlphaChannel = "keepAlpha"
        case hardwareAcceleration
    }

    // Decodable conformation
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // Parse basic/unmodified keys
        let quality = try? values.decode(Double?.self, forKey: .quality)
        let frameRate = try? values.decode(Int?.self, forKey: .frameRate)
        let preserveAlphaChannel = (try? values.decode(Bool?.self, forKey: .preserveAlphaChannel)) ?? true

        // Codec
        var codec: AVVideoCodecType?
        if let codecId = try? values.decode(String?.self, forKey: .codec) {
            codec = AVVideoCodecType(rawValue: codecId)
        }

        // Video size
        var size: CGSize?
        if let width = try? values.decode(Double?.self, forKey: .width),
            let height = try? values.decode(Double?.self, forKey: .height) {
            size = CGSize(width: width, height: height)
        }

        // Hardware acceleration
        let hardwareAcceleration: CompressionHardwareAcceleration
        if (try? values.decode(Bool?.self, forKey: .hardwareAcceleration)) == false {
            hardwareAcceleration = .disabled
        } else {
            hardwareAcceleration = .auto
        }

        // Bitrate
        let bitrate: CompressionVideoBitrate
        if let customBitrate = try? values.decode(Int?.self, forKey: .bitrate) {
            bitrate = .value(customBitrate)
        } else {
            bitrate = .auto
        }

        self.init(
            codec: codec,
            bitrate: bitrate,
            quality: quality,
            size: size == nil ? .original : .fit(size!),
            frameRate: frameRate,
            preserveAlphaChannel: preserveAlphaChannel,
            hardwareAcceleration: hardwareAcceleration
        )
    }
}

/// Implement JSON deserialization
extension CompressionAudioSettings: Decodable {
    private enum CodingKeys: String, CodingKey {
        case codec
        case bitrate
        case quality
        case sampleRate
    }

    // Decodable conformation
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // Codec
        let codec: CompressionAudioCodec
        if let codecId = try? values.decode(Int?.self, forKey: .codec),
            let audioCodec = CompressionAudioCodec(rawValue: codecId) {
            codec = audioCodec
        } else {
          codec = .default
        }

        // Custom bitrate value
        let bitrate: CompressionAudioBitrate
        if let customBitrate = try? values.decode(Int?.self, forKey: .bitrate) {
            bitrate = .value(customBitrate)
        } else {
            bitrate = .auto
        }

        // Audio quality
        var quality: AVAudioQuality?
        if let qualityValue = try? values.decode(Int?.self, forKey: .quality) {
            quality = AVAudioQuality(rawValue: qualityValue)
        }

        // Sample rate
        let sampleRate = try? values.decode(Int?.self, forKey: .sampleRate)

        self.init(
            codec: codec,
            bitrate: bitrate,
            quality: quality,
            sampleRate: sampleRate
        )
    }
}

/// Implement JSON deserialization
extension ImageSettings: Decodable {
    private enum CodingKeys: String, CodingKey {
        case format
        case width, height, crop // size
        case quality
        case frameRate
        case skipAnimation
        case preserveAlphaChannel = "keepAlpha"
        case embedThumbnail
        case optimizeColorForSharing = "optimizeColors"
        case backgroundColor
    }

    // Decodable conformation
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // Parse basic/unmodified keys
        let quality = try? values.decode(Double?.self, forKey: .quality)
        let frameRate = try? values.decode(Int?.self, forKey: .frameRate)
        let skipAnimation = (try? values.decode(Bool?.self, forKey: .skipAnimation)) ?? false
        let preserveAlphaChannel = (try? values.decode(Bool?.self, forKey: .preserveAlphaChannel)) ?? true
        let embedThumbnail = (try? values.decode(Bool?.self, forKey: .embedThumbnail)) ?? false
        let optimizeColorForSharing = (try? values.decode(Bool?.self, forKey: .optimizeColorForSharing)) ?? false

        // Retreive format from the string id
        var format: ImageFormat?
        if let formatId = try? values.decode(String?.self, forKey: .format) {
            format = ImageFormat(rawValue: formatId)
        }

        // Initialize `ImageSize` via passed width, height and crop fields
        let size: ImageSize
        if let width = try? values.decode(Double?.self, forKey: .width),
            let height = try? values.decode(Double?.self, forKey: .height) {
            let resolution = CGSize(width: width, height: height)
            let crop = (try? values.decode(Bool?.self, forKey: .crop)) ?? false
            size = crop ? .crop(options: Crop(size: resolution)) : .fit(resolution)
        } else {
            size = .original
        }

        // Convert 32-bit integer color value to `CGColor`
        var backgroundColor: CGColor?
        if let color = try? values.decode(Int?.self, forKey: .backgroundColor) {
            let alpha = (color >> 24) & 0xFF
            let red = (color >> 16) & 0xFF
            let green = (color >> 8) & 0xFF
            let blue = color & 0xFF

            backgroundColor = CGColor(
                red: Double(red) / 255.0,
                green: Double(green) / 255.0,
                blue: Double(blue) / 255.0,
                alpha: Double(alpha) / 255.0
            )
        }

        self.init(
            format: format,
            size: size,
            quality: quality,
            frameRate: frameRate,
            skipAnimation: skipAnimation,
            preserveAlphaChannel: preserveAlphaChannel,
            embedThumbnail: embedThumbnail,
            optimizeColorForSharing: optimizeColorForSharing,
            backgroundColor: backgroundColor
        )
    }
}
