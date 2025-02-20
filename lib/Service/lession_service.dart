import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/constants.dart';

class LessonModel {
  final int? lessonId;
  final String? title;
  final String? description;
  final int? stepOrder;
  final String? imageUrl;

  LessonModel({
    required this.lessonId,
    required this.title,
    required this.description,
    required this.stepOrder,
    required this.imageUrl,
  });

  // Factory constructor to create a LessonModel from JSON
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lessonId'],
      title: json['title'],
      description: json['description'],
      stepOrder: json['stepOrder'],
      imageUrl: json['imageUrl'],
    );
  }

  // Method to convert LessonModel to JSON (optional, if needed)
  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'stepOrder': stepOrder,
      'imageUrl': imageUrl,
    };
  }
}

Future<List<LessonModel>> fetchLessons() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('${Constants.baseUrl}/Lesson'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((lesson) => LessonModel.fromJson(lesson)).toList();
  } else {
    throw Exception('Failed to load lessons');
  }
}

