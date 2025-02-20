import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String videoName;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.videoName,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  Duration _currentPosition = Duration.zero; // To track current playback position

  @override
  void initState() {
    super.initState();

    // Ensure the video URL is valid

    // todo: make url dynamic
    Uri videoUri = Uri.parse("https://www.w3schools.com/html/movie.mp4");
    _controller = VideoPlayerController.network(videoUri.toString())
      ..addListener(_updatePosition) // Add listener for position updates
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play(); // Auto-play the video
      }).catchError((error) {
        setState(() {
          _isInitialized = false;
        });
      });
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePosition); // Remove the listener
    _controller.dispose(); // Clean up the controller
    super.dispose();
  }

  // Update the current playback position
  void _updatePosition() {
    setState(() {
      _currentPosition = _controller.value.position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.videoName),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : const CircularProgressIndicator(), // Show a loader while the video initializes
            ),
          ),
          if (_isInitialized)
            Column(
              children: [
                // Custom Slider for Playback Control
                Row(
                  children: [
                    // Current position
                    Text(
                      _formatDuration(_currentPosition),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentPosition.inSeconds.toDouble(),
                        max: _controller.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _controller.seekTo(Duration(seconds: value.toInt()));
                          });
                        },
                      ),
                    ),
                    // Total duration
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      )
          : null,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
