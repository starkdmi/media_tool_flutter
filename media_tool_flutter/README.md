## Media Tool Flutter

> Video, image and audio processing via native platform code.

## 🚧 WIP 🚧

Only Apple (iOS & macOS) support is implemented via native code yet. The Android implementation is mocked using `FFmpeg`.

## About

Flutter plugin for advanced media manipulation using native platform code. Supported media types are `video`, `audio` and `image`.

## Native Frameworks

| Platform | Framework |
| --- | --- |
| Apple | [MediaToolSwift](https://github.com/starkdmi/MediaToolSwift) |
| Android | MediaCodec\* | 
| Windows & Linux | OpenCL | 
| Web| None \| [FFmpeg](https://github.com/ffmpegwasm/ffmpeg.wasm) |

\* FFmpeg based [media_tool_ffmpeg](https://github.com/starkdmi/media_tool_ffmpeg) implementation is __temporarily__ used.

## Video

### Features:
- Compress with multiple codecs
- Resize
- Frame rate adjustment
- Audio track manipulataion
- Alpha channel and HDR handling
- Slow motion support
- Metadata preserving
- Hardware acceleration
- Thumbnails extraction
- Video information gathering
- Progress and cancellation

### Codecs

__Video__: `H.264`, `H.265/HEVC` and `ProRes`.

__Audio__: `AAC`, `Opus` and `FLAC`.

### Example

```Dart
// Compress video file
final task = VideoTool.compress(
  id: id, // unique id
  path: path,
  destination: destination,
  // Video
  videoSettings: const VideoSettings(
    codec: VideoCodec.h264,
    bitrate: 2000000, // 2 Mbps
    size: Size(1280.0, 1280.0), // size to fit in
    // quality, frame rate, atd.
  ),
  // Audio
  skipAudio: false,
  audioSettings: const AudioSettings(
    codec: AudioCodec.opus, 
    bitrate: 96000, // 96 Kbps
    // sample rate, quality, atd.
  ),
  // Metadata and file options
  skipMetadata: false,
  overwrite: true,
  deleteOrigin: false
);

// State notifier
task.events.listen(print);

// Cancellation
task.cancel();
```

## Image

### Features:
- Convert with multiple formats
- Resize and crop
- Frame rate adjustment
- Animated image sequences support
- Alpha channel and HDR handling
- Metadata and orientation preserving
- Image information gathering

### Formats:
- `JPEG`
- `PNG` and `APNG`
- `GIF`
- `TIFF`
- `BMP`
- `WEBP`
- `HEIF`

### Example

```Dart
// Convert image file
final metadata = await ImageTool.compress(
  path: path,
  destination: destination,
  settings: const ImageSettings(
    format: ImageFormat.png,
    size: Size(1280.0, 1280.0),
    crop: false, // crop or fit
    // frame rate, quality, alpha channel, background color, atd.
  ),
  skipMetadata: false,
  overwrite: true,
  deleteOrigin: false
);
```

## Audio

### Features:
- Compress with multiple codecs
- Metadata preserving
- Hardware acceleration
- Audio information gathering
- Progress and cancellation

### Codecs:
- `AAC`
- `Opus`
- `FLAC`

### Example

```Dart
// Compress audio file
final task = AudioTool.compress(
  id: id, // unique id
  path: path,
  destination: destination,
  settings: const AudioSettings(
    codec: AudioCodec.opus, 
    bitrate: 96000, // 96 Kbps
    // sample rate, quality, atd.
  ),
  skipMetadata: false,
  overwrite: true,
  deleteOrigin: false
);

// State notifier
task.events.listen(print);

// Cancellation
task.cancel();
```

## Internally

Each plugin methods which run platform code do support multiple parallel executions, each of execution has it's own progress, cancellation and error handling. Main tests stored at [integration_test](media_tool/example/integration_test/).

## License

The Plugin is licensed under the MIT. The platform implementations may have their own licenses:
- MediaToolSwift - Mozilla Public License 2.0
- media_tool_ffmpeg - LGPL V2.1
