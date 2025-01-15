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
    _videoFuture = VideoService().fetchVideosByLessonId(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Videos"),
      ),
      body: FutureBuilder<List<VideoModel>>(
        future: _videoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No videos found"));
          }

          final videos = snapshot.data!;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return ListTile(
                leading: Image.network(video.imageUrl!, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(video.name!),
                subtitle: Text(video.description!),
                  onTap: () {
                    final videoUrl = Uri.encodeComponent(video.videoUrl!);
                    final videoName = Uri.encodeComponent(video.name!);

                    context.go('/videoPlayer?videoUrl=$videoUrl&videoName=$videoName');
                  }
              );
            },
          );
        },
      ),
    );
  }
}
