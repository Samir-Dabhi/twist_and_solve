import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/constants.dart';

class Algorithm {
  final int algorithmId;
  final String name;
  final String notation;
  final String? description;
  final int? lessonId;
  final String? imageUrl;
  final String? category;

  Algorithm({
    required this.algorithmId,
    required this.name,
    required this.notation,
    this.description,
    this.lessonId,
    this.imageUrl,
    this.category,
  });

  factory Algorithm.fromJson(Map<String, dynamic> json) {
    return Algorithm(
      algorithmId: json['algorithmId'],
      name: json['name'],
      notation: json['notation'],
      description: json['description'],
      lessonId: json['lessonId'],
      imageUrl: json['imageUrl'],
      category: json['category'],
    );
  }
}

Future<List<Algorithm>> fetchAlgorithms() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not logged in or token missing.');
    }

    const String url = '${Constants.baseUrl}/Algorithm';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Algorithm.fromJson(data)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}

Future<List<Algorithm>> fetchAlgorithmsByCategory(String Category) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not logged in or token missing.');
    }

    String url = '${Constants.baseUrl}/Algorithm/Category/$Category';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Algorithm.fromJson(data)).toList();
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}