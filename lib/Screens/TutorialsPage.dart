import 'package:flutter/material.dart';
// Import your custom app bar
import 'appbar.dart';

import 'package:video_player/video_player.dart'; // Add video_player package for video player

class WorkoutDetailScreen extends StatefulWidget {
  final String workout;

  WorkoutDetailScreen({required this.workout});

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the video controller with a sample video
    _controller = VideoPlayerController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4', // Replace with your workout video URL
    )..initialize().then((_) {
      setState(() {}); // Update the UI once video is loaded
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Dispose of the video controller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Use the custom app bar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  widget.workout,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                  ),
                  // Left arrow
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        // Handle previous video navigation
                      },
                    ),
                  ),
                  // Right arrow
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        // Handle next video navigation
                      },
                    ),
                  ),
                ],
              ),
            )
                : Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
