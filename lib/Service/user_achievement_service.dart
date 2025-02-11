import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/Service/achievement_service.dart';

class Achievement {
  final int userAchievementId;
  final int userId;
  final int achievementId;
  final String title;
  final String description;
  final DateTime dateAchieved;
  final String iconUrl;

  Achievement({
    required this.userAchievementId,
    required this.userId,
    required this.achievementId,
    required this.title,
    required this.description,
    required this.dateAchieved,
    required this.iconUrl
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      userAchievementId: json['userAchievementId'],
      userId: json['userId'],
      achievementId: json['achievementId'],
      title: json['title'],
      description: json['description'],
      dateAchieved: DateTime.parse(json['dateEarned']),
      iconUrl: json['iconURL']
    );
  }
}

Future<List<Achievement>> fetchUserAchievements() async {
  List<Achievements> achievements = await fetchAchievements();
  print('achievements = ');
  print(achievements[0].title);
  final prefs = await SharedPreferences.getInstance();
  dynamic userInfoJson = prefs.getString('userInfo');
  dynamic userInfo = jsonDecode(userInfoJson!);
  int userId = userInfo['userId'];
  final response = await http.get(
    Uri.parse('http://localhost:5167/UserAchievement/user/$userId'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Achievement.fromJson(json)).toList();
  }
  else if(response.statusCode == 404) {
    throw Exception('No User Achievement found');
  }
  else{
    throw Exception('Error fetching Achievement');
  }
}

