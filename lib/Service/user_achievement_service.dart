import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/Service/achievement_service.dart';
import 'package:twist_and_solve/constants.dart';

class UserAchievement {
  final int userAchievementId;
  final int userId;
  final int achievementId;
  final String title;
  final String description;
  final DateTime dateAchieved;
  final String iconUrl;

  UserAchievement({
    required this.userAchievementId,
    required this.userId,
    required this.achievementId,
    required this.title,
    required this.description,
    required this.dateAchieved,
    required this.iconUrl
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
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

// Fetch user achievements
Future<List<UserAchievement>> fetchUserAchievements() async {
  List<Achievements> achievements = await fetchAchievements();
  debugPrint('achievements = ');
  debugPrint(achievements[0].title);

  final prefs = await SharedPreferences.getInstance();
  final userInfoJson = prefs.getString('userInfo');
  final token = prefs.getString('token'); // Retrieve the token

  if (userInfoJson == null || token == null) {
    throw Exception('User not logged in or token missing.');
  }

  final userInfo = jsonDecode(userInfoJson);
  int userId = userInfo['userId'];

  final response = await http.get(
    Uri.parse('${Constants.baseUrl}/UserAchievement/user/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => UserAchievement.fromJson(json)).toList();
  } else if (response.statusCode == 404) {
    throw Exception('No User Achievement found');
  } else {
    throw Exception('Error fetching Achievement');
  }
}

// Post user achievement
Future<void> postUserAchievement(int achievementId) async {
  String apiUrl = '${Constants.baseUrl}/UserAchievement';

  try {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString('userInfo');
    final token = prefs.getString('token');

    if (userInfoJson == null || token == null) {
      throw Exception('User not logged in or token missing.');
    }

    final userInfo = jsonDecode(userInfoJson);
    final userId = userInfo['userId'];

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "userAchievementId": 0, // Assuming API auto-generates ID
        "userId": userId,
        "achievementId": achievementId,
        "dateEarned": DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      debugPrint('Achievement posted successfully!');
    } else {
      debugPrint('Failed to post achievement: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error posting achievement: $e');
  }
}

// Fetch user achievements status
Future<Map<int, bool>> fetchUserAchievementsStatus() async {
  String allAchievementsUrl = '${Constants.baseUrl}/Achievement';
  String userAchievementsUrl = '${Constants.baseUrl}/UserAchievement/user';

  try {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString('userInfo');
    final token = prefs.getString('token');

    if (userInfoJson == null || token == null) {
      throw Exception('User not logged in or token missing.');
    }

    final userInfo = jsonDecode(userInfoJson);
    final userId = userInfo['userId'];

    final allAchievementsResponse = await http.get(
      Uri.parse(allAchievementsUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (allAchievementsResponse.statusCode != 200) {
      throw Exception('Failed to load all achievements');
    }

    List<dynamic> allAchievementsData = json.decode(allAchievementsResponse.body);
    Map<int, bool> achievementStatus = {
      for (var achievement in allAchievementsData) achievement['achievementId']: false
    };

    final userAchievementsResponse = await http.get(
      Uri.parse('$userAchievementsUrl/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (userAchievementsResponse.statusCode == 200) {
      List<dynamic> userAchievementsData = json.decode(userAchievementsResponse.body);
      for (var achievement in userAchievementsData) {
        int achievementId = achievement['achievementId'];
        achievementStatus[achievementId] = true;
      }
    }

    return achievementStatus;
  } catch (e) {
    return {};
  }
}
