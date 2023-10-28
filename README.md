## Media Tool Flutter

> Video, image and audio processing via native platform code.

## WIP

Only Apple (iOS & macOS) support is implemented yet.

## About

Flutter plugin allows advanced media manipulation using native platform code. Media types and operations:
- **Video**: compress/convert, resize, crop, trim, rotate, frame rate, apply filters, video stabilization, audio track manipulataion, metadata processing, thumbnail, animated video previews, video information

- **Image**: convert, resize, crop, rotate, flip, remove background, apply filters, adjust frame rate, thumbnail, image information

- **Audio**: convert, cut, adjust speed, generate waveworm data, audio information

## Video

### Native Frameworks

- **Apple**: _VideoToolBox_ via [MediaToolSwift](https://github.com/starkdmi/MediaToolSwift)

- **Android**: _MediaCodec_ via [Transcoder](https://github.com/natario1/Transcoder) or [LightCompressor](https://github.com/AbedElazizShe/LightCompressor)

- **Windows and Linux**: _OpenCL_

- **Web**:  _None_ **or** _[FFmpeg](https://github.com/ffmpegwasm/ffmpeg.wasm)_ - [Dart only](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#dart-only-platform-implementations) using [ffmpeg_wasm](https://pub.dev/packages/ffmpeg_wasm)

### Example

```Dart
// Compress video file
final task = VideoTool.compress(
  id: id,
  path: path,
  destination: destination,
  videoSettings: const VideoSettings(
    codec: VideoCodec.h264,
    bitrate: 2000000,
    size: Size(1280.0, 1280.0),
  ),
  skipAudio: false,
  audioSettings: const AudioSettings(
    codec: AudioCodec.opus, 
    bitrate: 96000, 
  ),
  overwrite: true,
  deleteOrigin: false
);

// State notifier
task.events.listen((event) { 
  print(event)
});

// Cancellation
task.cancel();
```

## Internally

Each plugin methods which run platform code do support multiple parallel executions, each of execution has it's own progress, cancellation and error handling. Main tests stored at [integration_test](media_tool/example/integration_test/).

## License

The Plugin is licensed under the MIT. The platform implementations may have their own licenses:
- MediaToolSwift - Mozilla Public License 2.0