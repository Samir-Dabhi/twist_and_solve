import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:twist_and_solve/constants.dart';

class Algorithm {
  final int algorithmId;
  final String name;
  final String notation;
  final String? description;
  final int? lessonId;

  Algorithm({
    required this.algorithmId,
    required this.name,
    required this.notation,
    this.description,
    this.lessonId,
  });

  factory Algorithm.fromJson(Map<String, dynamic> json) {
    return Algorithm(
      algorithmId: json['algorithmId'],
      name: json['name'],
      notation: json['notation'],
      description: json['description'],
      lessonId: json['lessonId'],
    );
  }
}

Future<List<Algorithm>> fetchAlgorithms() async {

  final String url = '${Constants.baseUrl}/Algorithm';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Algorithm.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load algorithms');
  }
}