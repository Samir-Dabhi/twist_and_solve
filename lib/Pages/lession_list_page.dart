import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twist_and_solve/Service/lession_service.dart';

class LessonListPage extends StatefulWidget {
  const LessonListPage({Key? key}) : super(key: key);

  @override
  State<LessonListPage> createState() => _LessonListPageState();
}

class _LessonListPageState extends State<LessonListPage> {
  late Future<List<LessonModel>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch lessons when the page initializes
    _lessonsFuture = fetchLessons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
      ),
      body: FutureBuilder<List<LessonModel>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading spinner while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message with a retry button
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _lessonsFuture = fetchLessons();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show a message if no lessons are available
            return const Center(child: Text('No lessons available'));
          } else {
            final lessons = snapshot.data!;

            return ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: lesson.imageUrl != null && lesson.imageUrl!.isNotEmpty
                          ? Image.network(
                        lesson.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback icon if image fails to load
                          return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                        },
                      )
                          : const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                    title: Text(
                      lesson.title ?? 'Untitled Lesson',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Step: ${lesson.stepOrder}\n${lesson.description ?? 'No description available'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      // Navigate to the video list for the selected lesson
                      context.go('/videos/${lesson.lessonId}');
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
