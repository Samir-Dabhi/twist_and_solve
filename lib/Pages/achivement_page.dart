import 'package:flutter/material.dart';
import 'package:twist_and_solve/Service/achievement_service.dart';

class AchivementPage extends StatelessWidget {
  const AchivementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Achievements')),
      body: FutureBuilder<List<Achievement>>(
        future: fetchUserAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No achievements found.'));
          } else {
            final achievements = snapshot.data!;
            return ListView.builder(
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.emoji_events_outlined),
                    title: Text(achievement.title),
                    subtitle: Text(achievement.description),
                    trailing: Text(
                      '${achievement.dateAchieved.toLocal()}'.split(' ')[0],
                      style: const TextStyle(color: Colors.grey),
                    ),
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
