import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:twist_and_solve/constants.dart';

class VideoService {
  static const String baseUrl = Constants.baseUrl;

  Future<List<VideoModel>> fetchVideosByLessonId(int lessonId) async {
    final url = Uri.parse('$baseUrl/Video/ByLessonId/$lessonId'); // Replace with actual endpoint

    //print
    print(url.toString());
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> videoJson = json.decode(response.body);
      return videoJson.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load videos");
    }
  }
}


class VideoModel {
  final int? videoId;
  final String? name;
  final String? description;
  final int? lessonId;
  final String? videoUrl;
  final String? imageUrl;

  VideoModel({
    required this.videoId,
    required this.name,
    required this.description,
    required this.lessonId,
    required this.videoUrl,
    required this.imageUrl,
  });

  // Factory method to create an instance from JSON
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: json['videoId'],
      name: json['name'],
      description: json['description'],
      lessonId: json['lessonId'],
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
    );
  }
}
