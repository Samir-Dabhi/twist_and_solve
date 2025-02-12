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

Future<List<UserAchievement>> fetchUserAchievements() async {
  List<Achievements> achievements = await fetchAchievements();
  debugPrint('achievements = ');
  debugPrint(achievements[0].title);
  final prefs = await SharedPreferences.getInstance();
  dynamic userInfoJson = prefs.getString('userInfo');
  dynamic userInfo = jsonDecode(userInfoJson!);
  int userId = userInfo['userId'];
  final response = await http.get(
    Uri.parse('http://localhost:5167/UserAchievement/user/$userId'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => UserAchievement.fromJson(json)).toList();
  }
  else if(response.statusCode == 404) {
    throw Exception('No User Achievement found');
  }
  else{
    throw Exception('Error fetching Achievement');
  }
}

Future<void> postUserAchievement(int achievementId) async {
  String apiUrl = '${Constants.baseUrl}/UserAchievement'; // Use base URL from Constants

  try {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString('userInfo');

    if (userInfoJson == null) {
      throw Exception('User not logged in.');
    }

    final userInfo = jsonDecode(userInfoJson) as Map<String, dynamic>;
    final userId = userInfo['userId'];

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
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

Future<Map<int, bool>> fetchUserAchievementsStatus() async {
  String allAchievementsUrl = '${Constants.baseUrl}/Achievement'; // Fetch all achievements
  String userAchievementsUrl = '${Constants.baseUrl}/UserAchievement/user'; // Fetch user-earned achievements

  try {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString('userInfo');

    if (userInfoJson == null) {
      throw Exception('User not logged in.');
    }

    final userInfo = jsonDecode(userInfoJson) as Map<String, dynamic>;
    final userId = userInfo['userId'];

    // Fetch all achievements
    final allAchievementsResponse = await http.get(Uri.parse(allAchievementsUrl));
    if (allAchievementsResponse.statusCode != 200) {
      throw Exception('Failed to load all achievements');
    }
    List<dynamic> allAchievementsData = json.decode(allAchievementsResponse.body);

    // Initialize achievement status map with all achievements set to false
    Map<int, bool> achievementStatus = {
      for (var achievement in allAchievementsData) achievement['achievementId']: false
    };

    // Fetch user-earned achievements
    final userAchievementsResponse = await http.get(Uri.parse('$userAchievementsUrl/$userId'));
    if (userAchievementsResponse.statusCode == 200) {
      List<dynamic> userAchievementsData = json.decode(userAchievementsResponse.body);
      print(userAchievementsData);
      // Mark achievements as earned
      for (var achievement in userAchievementsData) {
        int achievementId = achievement['achievementId'];
        achievementStatus[achievementId] = true;
      }
    }
    print(userId);
    print(achievementStatus);
    return achievementStatus;
  } catch (e) {
    print('Error fetching achievements: $e');
    return {}; // Return an empty map on error
  }
}