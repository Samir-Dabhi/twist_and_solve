import 'package:flutter/material.dart';
import 'package:twist_and_solve/Service/achievement_service.dart';
import 'package:twist_and_solve/Service/user_achievement_service.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Achievements')),
      body: FutureBuilder<Map<int, bool>>(
        future: fetchUserAchievementsStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No achievements found.'));
          } else {
            final achievementStatus = snapshot.data!;

            // Separate earned and not earned achievements
            final earnedAchievements = achievementStatus.entries
                .where((entry) => entry.value == true)
                .map((entry) => entry.key)
                .toList();

            final notEarnedAchievements = achievementStatus.entries
                .where((entry) => entry.value == false)
                .map((entry) => entry.key)
                .toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Earned Achievements Section
                  if (earnedAchievements.isNotEmpty)
                    _buildAchievementSection(
                        context, "Earned Achievements", earnedAchievements, true),

                  // Not Earned Achievements Section
                  if (notEarnedAchievements.isNotEmpty)
                    _buildAchievementSection(
                        context, "Not Earned Achievements", notEarnedAchievements, false),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Widget to build achievement sections
  Widget _buildAchievementSection(
      BuildContext context, String title, List<int> achievementIds, bool isEarned) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            itemCount: achievementIds.length,
            itemBuilder: (context, index) {
              final achievementId = achievementIds[index];

              return FutureBuilder<Achievements>(
                future: fetchAchievementById(achievementId),
                builder: (context, achievementSnapshot) {
                  if (achievementSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (achievementSnapshot.hasError || !achievementSnapshot.hasData) {
                    return const Center(child: Icon(Icons.error));
                  } else {
                    final achievement = achievementSnapshot.data!;

                    return GestureDetector(
                      onTap: () => _showAchievementDetails(context, achievement),
                      child: Card(
                        elevation: 4,
                        color: isEarned ? Colors.white : Colors.grey.shade300, // Dim non-earned
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Opacity(
                                opacity: isEarned ? 1.0 : 0.5, // Dim non-earned
                                child: Image.network(
                                  achievement.iconUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              achievement.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isEarned ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Show achievement details dialog
  //TODO give proper discription when earned or not
  void _showAchievementDetails(BuildContext context, Achievements achievement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(achievement.title,style: const TextStyle(
            color: Colors.blue
          ),)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  achievement.iconUrl,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Text(achievement.description)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close',
                style: TextStyle(
                  color: Colors.blue
              ),),
            ),
          ],
        );
      },
    );
  }
}
