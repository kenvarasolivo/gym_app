import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubeVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const YouTubeVideoPlayer({super.key, required this.videoUrl});

  @override
  State<YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    
    // 1. Initialize Controller
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _extractVideoId(widget.videoUrl),
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  // Helper to extract ID from various YouTube URL formats
  String _extractVideoId(String url) {
    // youtube_player_iframe handles simple IDs, but we can use this logic 
    // to ensure we pass a clean ID if the package doesn't parse your specific URL format.
    // The package also has a helper: YoutubePlayerController.convertUrlToId(url)
    return YoutubePlayerController.convertUrlToId(url) ?? '';
  }

  @override
  void dispose() {
    // The iframe controller cleans itself up, but we can close it if needed
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}