import MediaToolSwift
import AVFoundation

/// Implement JSON serialization
extension ImageInfo: Encodable {
    private enum CodingKeys: String, CodingKey {
        case format
        case width, height // size
        case hasAlpha
        case isHDR
        case orientation
        case framesCount
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
        try container.encode(framesCount, forKey: .framesCount)
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
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        time = try values.decode(Double.self, forKey: .time)
        url = try values.decode(URL.self, forKey: .url)
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
        try container.encode(url.absoluteString, forKey: .url)
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
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // Parse basic/unmodified keys
        quality = try? values.decode(Double?.self, forKey: .quality)
        frameRate = try? values.decode(Int?.self, forKey: .frameRate)
        preserveAlphaChannel = (try? values.decode(Bool?.self, forKey: .preserveAlphaChannel)) ?? true

        // Codec
        if let codecId = try? values.decode(String?.self, forKey: .codec) {
            codec = AVVideoCodecType(rawValue: codecId)
        }

        // Video size
        if let width = try? values.decode(Double?.self, forKey: .width),
            let height = try? values.decode(Double?.self, forKey: .height) {
            size = CGSize(width: width, height: height)
        }

        // Hardware acceleration
        if (try? values.decode(Bool?.self, forKey: .hardwareAcceleration)) == false {
            hardwareAcceleration = .disabled
        } else {
            hardwareAcceleration = .auto
        }

        // Bitrate
        if let customBitrate = try? values.decode(Int?.self, forKey: .bitrate) {
            bitrate = .value(customBitrate)
        } else {
            bitrate = .auto
        }
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
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // Codec
        if let codecId = try? values.decode(Int?.self, forKey: .codec),
            let audioCodec = CompressionAudioCodec(rawValue: codecId) {
            codec = audioCodec
        } else {
          codec = .default
        }

        // Custom bitrate value
        if let customBitrate = try? values.decode(Int?.self, forKey: .bitrate) {
            bitrate = .value(customBitrate)
        } else {
            bitrate = .auto
        }

        // Audio quality
        if let qualityValue = try? values.decode(Int?.self, forKey: .quality) {
            quality = AVAudioQuality(rawValue: qualityValue)
        }

        // Sample rate
        sampleRate = try? values.decode(Int?.self, forKey: .sampleRate)
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
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)

        // Parse basic/unmodified keys
        quality = try? values.decode(Double?.self, forKey: .quality)
        frameRate = try? values.decode(Int?.self, forKey: .frameRate)
        skipAnimation = (try? values.decode(Bool?.self, forKey: .skipAnimation)) ?? false
        preserveAlphaChannel = (try? values.decode(Bool?.self, forKey: .preserveAlphaChannel)) ?? true
        embedThumbnail = (try? values.decode(Bool?.self, forKey: .embedThumbnail)) ?? false
        optimizeColorForSharing = (try? values.decode(Bool?.self, forKey: .optimizeColorForSharing)) ?? false

        // Retreive format from the string id
        if let formatId = try? values.decode(String?.self, forKey: .format) {
            format = ImageFormat(rawValue: formatId)
        }

        // Initialize `ImageSize` via passed width, height and crop fields
        if let width = try? values.decode(Double?.self, forKey: .width),
            let height = try? values.decode(Double?.self, forKey: .height) {
            let resolution = CGSize(width: width, height: height)
            let crop = (try? values.decode(Bool?.self, forKey: .crop)) ?? false
            size = crop ? .crop(options: Crop(size: resolution)) : .fit(resolution)
        } else {
            size = .original
        }

        // Convert array of color components to `CGColor`
        let backgroundColorComponents: [Int] = (try? values.decode([Int].self, forKey: .backgroundColor)) ?? []
        if !backgroundColorComponents.isEmpty, backgroundColorComponents.count >= 3 {
            let red = backgroundColorComponents[0]
            let green = backgroundColorComponents[1]
            let blue = backgroundColorComponents[2]
            let alpha = backgroundColorComponents.count >= 4 ? backgroundColorComponents[3] : 255
            backgroundColor = CGColor(
                red: Double(red) / 255.0,
                green: Double(green) / 255.0,
                blue: Double(blue) / 255.0,
                alpha: Double(alpha) / 255.0
            )
        }
    }
}
