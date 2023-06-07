## Media Tool Flutter

> Video, image and audio processing via native platform code.

## WIP

Only Apple platforms are supported for now and only the main video operations.

## About

Flutter plugin allows advanced media manipulation using native platform code. Media types and operations:
- **Video**: compress/convert, resize, crop, trim, rotate, frame rate, apply filters, video stabilization, audio track manipulataion, metadata processing, thumbnail, animated video previews, video information

- **Image**: convert, resize, crop, rotate, flip, remove background, apply filters, adjust frame rate, thumnail, image information

- **Audio**: convert, cut, adjust speed, generate waveworm data, audio information

## Video

**WIP** - Only video compressor is implemented (!)

### Native Frameworks

- **Apple**: _VideoToolBox_ via [MediaToolSwift](https://github.com/starkdmi/MediaToolSwift)

- **Android**: _MediaCodec_ via [Transcoder](https://github.com/natario1/Transcoder)

- **Windows and Linux**: _OpenCL_

- **Web**:  _None_ or _[FFmpeg](https://github.com/ffmpegwasm/ffmpeg.wasm)_ - [Dart only](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#dart-only-platform-implementations) using [ffmpeg_wasm](https://pub.dev/packages/ffmpeg_wasm)

### Example

```Dart
final task = VideoTool.compress(
  id: id,
  path: path,
  destination: destination,
  videoSettings: const VideoSettings(
    codec: VideoCodec.h265,
    bitrate: 2000000,
    quality: 0.75,
    size: Size(1280.0, 1280.0),
  ),
  skipAudio: false,
  audioSettings: const AudioSettings(
    codec: AudioCodec.opus, 
    bitrate: 96000, 
    sampleRate: 44100
  ),
  overwrite: true,
  deleteOrigin: false
);
```

## Internally

Each plugin methods which run platform code do support multiple parallel executions, each of execution has it's own progress, cancellation and error handling. Main tests stored at [integration_test](media_tool/example/integration_test/).

## License

The Plugin is licensed under the MIT. The platform implementation may have their own licenses:
- MediaToolSwift - Mozilla Public License 2.0