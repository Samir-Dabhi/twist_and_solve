import 'package:flutter/material.dart';
import 'package:twist_and_solve/Service/lession_service.dart';

class Lessionlistpage extends StatefulWidget {
  const Lessionlistpage({super.key});
  @override
  State<Lessionlistpage> createState() => _LessionlistpageState();
}

class _LessionlistpageState extends State<Lessionlistpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
      ),
      body: FutureBuilder<List<LessonModel>>(
        future: fetchLessons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No lessons available'));
          } else {
            final lessons = snapshot.data!;
            return ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: lesson.imageUrl.isNotEmpty
                        ? Image.network(lesson.imageUrl, width: 50,
                        height: 50,
                        fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50),
                    title: Text(lesson.title),
                    subtitle: Text(
                      'Step: ${lesson.stepOrder}\n${lesson.description}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Handle lesson tap (navigate to details or perform actions)
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
