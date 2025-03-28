import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twist_and_solve/Components/ErrorPage.dart';
import 'package:twist_and_solve/Service/lession_service.dart';
import 'package:twist_and_solve/Service/video_service.dart';

class VideoListPage extends StatefulWidget {
  final int lessonId;

  const VideoListPage({super.key, required this.lessonId});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  late Future<List<VideoModel>> _videoFuture;
  late LessonModel lesson;
  @override
  void initState() {
    super.initState();
    // Fetch videos when the page initializes
    _videoFuture = VideoService().fetchVideosByLessonId(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchLessonsByID(widget.lessonId),
      builder: (context,snapshot1){
        if (snapshot1.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        else if (snapshot1.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Failed to load Lesson Banner.Error: ${snapshot1.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }
        else if (!snapshot1.hasData) {
          return const Center(child: Text("No videos found for this lesson."));
        }
        else{
          return FutureBuilder<List<VideoModel>>(
            future: _videoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              else if (snapshot.hasError) {return Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ErrorComponent(ErrorText:snapshot.error.toString().replaceAll("Exception:", ""))
                ),
              );
              }
              else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No videos found for this lesson."));
              }
              final videos = snapshot.data!;
              return Scaffold(
                body: Column(

                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12.0,12.0,12.0,0),
                      child: BannerWidget(imageUrl: snapshot1.data!['imageUrl'] ?? '', lessonDescription: snapshot1.data!['title'] ?? ''),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // ✅ 2 videos per row
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.82,
                          ),

                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final video = videos[index];

                            return GestureDetector(
                              onTap: () {
                                final videoUrl = Uri.encodeComponent(video.videoUrl ?? '');
                                final videoName = Uri.encodeComponent(video.name ?? 'Video');
                                context.go('/videoPlayer?videoUrl=$videoUrl&videoName=$videoName');
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                      child: Image.network(
                                        video.imageUrl ?? '',
                                        width: double.infinity,
                                        height: 160,
                                        fit: BoxFit.scaleDown,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        video.name ?? "No Title",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },

    );
  }
}

class BannerWidget extends StatelessWidget {
  final String imageUrl;
  final String lessonDescription;

  const BannerWidget({super.key, required this.imageUrl, required this.lessonDescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          height: 190,
          width: double.infinity,
          fit: BoxFit.fitHeight,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }
}

