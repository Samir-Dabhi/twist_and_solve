import 'dart:convert';

import 'package:http/http.dart' as http;
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
      lessonId: json['lesson_id'],
      title: json['title'],
      description: json['description'],
      stepOrder: json['step_order'],
      imageUrl: json['image_url'],
    );
  }

  // Method to convert LessonModel to JSON (optional, if needed)
  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'title': title,
      'description': description,
      'step_order': stepOrder,
      'image_url': imageUrl,
    };
  }
}

Future<List<LessonModel>> fetchLessons() async {
  final response = await http.get(Uri.parse('http://10.70.20.214/Lesson'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((lesson) => LessonModel.fromJson(lesson)).toList();
  } else {
    throw Exception('Failed to load lessons');
  }
}
