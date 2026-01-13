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
        enableJavaScript: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );
  }

  // Helper to extract ID from various YouTube URL formats
  String _extractVideoId(String url) {
// Use the static helper provided by the package
  final id = YoutubePlayerController.convertUrlToId(url);
  if (id != null && id.length == 11) return id;
  
  // Manual fallback for shorts or unusual formats
  if (url.contains('/shorts/')) {
    final parts = url.split('/shorts/');
    if (parts.length > 1) {
      // Returns the ID and removes any trailing query parameters like ?cbrd=1
      return parts[1].split('?')[0].split('&')[0];
    }
  }
  
 // 3. Last resort: if the URL is already just an 11-char ID
  if (url.trim().length == 11) return url.trim();
  
  return '';
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16/9,
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
        )
      ),
    );
  }
}