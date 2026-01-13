import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              if (!_controller.value.isPlaying)
                GestureDetector(
                  onTap: () => _controller.play(),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.play_arrow, size: 40, color: Colors.white),
                  ),
                )
              else
                GestureDetector(
                  onTap: () => _controller.pause(),
                  child: const SizedBox.shrink(),
                ),
            ],
          ),
        ),
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: Theme.of(context).colorScheme.primary,
            bufferedColor: Colors.white38,
            backgroundColor: Colors.white12,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () => _controller.value.isPlaying ? _controller.pause() : _controller.play(),
              ),
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  final pos = _controller.value.position - const Duration(seconds: 10);
                  _controller.seekTo(pos > Duration.zero ? pos : Duration.zero);
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  final pos = _controller.value.position + const Duration(seconds: 10);
                  _controller.seekTo(pos < _controller.value.duration ? pos : _controller.value.duration);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
