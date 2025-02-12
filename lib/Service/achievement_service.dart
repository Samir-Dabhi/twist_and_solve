import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:twist_and_solve/constants.dart';

class Achievements {
  final int achievementId;
  final String title;
  final String description;
  final String iconUrl;

  Achievements({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.iconUrl,
  });

  // Factory method to create an Achievement from JSON
  factory Achievements.fromJson(Map<String, dynamic> json) {
    return Achievements(
      achievementId: json['achievementId'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['iconUrl'],
    );
  }
}
Future<List<Achievements>> fetchAchievements() async {
  final response = await http.get(Uri.parse('http://localhost:5167/Achievement'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    debugPrint(data.toString());
    return data.map((json) => Achievements.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load achievements');
  }
}
Future<Achievements> fetchAchievementById(int achievementId) async {
  final String url = '${Constants.baseUrl}/Achievement/$achievementId';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Achievements.fromJson(data);
    } else {
      throw Exception('Failed to load achievement with ID: $achievementId');
    }
  } catch (e) {
    throw Exception('Error fetching achievement: $e');
  }
}