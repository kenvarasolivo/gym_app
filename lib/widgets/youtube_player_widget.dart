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

  String _extractVideoId(String url) {
  final id = YoutubePlayerController.convertUrlToId(url);
  if (id != null && id.length == 11) return id;
  

  if (url.contains('/shorts/')) {
    final parts = url.split('/shorts/');
    if (parts.length > 1) {
      return parts[1].split('?')[0].split('&')[0];
    }
  }
  
  if (url.trim().length == 11) return url.trim();
  
  return '';
  }

  @override
  void dispose() {
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