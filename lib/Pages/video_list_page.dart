import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twist_and_solve/Service/video_service.dart';

class VideoListPage extends StatefulWidget {
  final int lessonId;

  const VideoListPage({Key? key, required this.lessonId}) : super(key: key);

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  late Future<List<VideoModel>> _videoFuture;

  @override
  void initState() {
    super.initState();
    // Fetch videos when the page initializes
    _videoFuture = VideoService().fetchVideosByLessonId(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Videos"),
      ),
      body: FutureBuilder<List<VideoModel>>(
        future: _videoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading spinner while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if the request fails
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Failed to load videos. Please try again later.\nError: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if there are no videos
            return const Center(child: Text("No videos found for this lesson."));
          }

          final videos = snapshot.data!;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.network(
                        video.imageUrl ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback image for invalid URLs
                          return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                        },
                      ),
                    ),
                    title: Text(
                      video.name ?? "No Title",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      video.description ?? "No Description Available",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Encode URL and name safely
                      final videoUrl = Uri.encodeComponent(video.videoUrl ?? '');
                      final videoName = Uri.encodeComponent(video.name ?? 'Video');

                      context.go('/videoPlayer?videoUrl=$videoUrl&videoName=$videoName');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
