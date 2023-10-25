import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_tool/media_tool.dart';
import 'package:media_tool_platform_interface/media_tool_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _uuid = const Uuid();
  VideoCompressionTask? _task;
  StreamSubscription<CompressionEvent>? _subscription;
  CompressionEvent? _event;

  @override void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MediaTool Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_event == null)
              const SizedBox.shrink()
            else
              Text(
                _event.toString(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _task = null;
                  _event = null;
                });

                final result = await FilePicker.platform.pickFiles();
                final path = result?.files.first.path;
                if (path == null) return;
                debugPrint(path);

                final temp = await getTemporaryDirectory();
                final destination = '${temp.path}/media_tool_compressed.mov';
                debugPrint(destination);

                final task = VideoTool.compress(
                  id: _uuid.v4(), 
                  path: path, 
                  destination: destination, 
                  videoSettings: const VideoSettings(
                    codec: VideoCodec.h265,
                    bitrate: 2000000,
                    // quality: 0.75,
                    size: Size(1280.0, 1280.0),
                  ),
                  skipAudio: true,
                  // audioSettings: const AudioSettings(codec: AudioCodec.opus, bitrate: 96000, sampleRate: 44100),
                  overwrite: true,
                );

                _subscription = task.events.listen((event) { 
                  setState(() => _event = event);

                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       backgroundColor: Theme.of(context).primaryColor,
                  //       content: Text('$error'),
                  //     ),
                  //   );
                });

                setState(() => _task = task);
              },
              child: const Text('Select video'),
            ),

            if (_task != null)
              ElevatedButton(
                onPressed: () async {
                  final cancelled = await _task?.cancel();
                  if (cancelled != true) { 
                    return; 
                  }
                  setState(() => _task = null);
                },
                child: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}
