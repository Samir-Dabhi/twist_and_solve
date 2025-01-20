import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/Service/auth_service.dart';
import 'package:twist_and_solve/constants.dart';



class SolveModel {
  final int solveId;
  final int userId;
  final double solveTime; // Time in seconds
  final DateTime solveDate;
  final String method;
  final int? movesCount;
  final String solveResult;
  final String scramble;

  SolveModel({
    required this.solveId,
    required this.userId,
    required this.solveTime,
    required this.solveDate,
    required this.method,
    this.movesCount,
    required this.solveResult,
    required this.scramble,
  });

  factory SolveModel.fromJson(Map<String, dynamic> json) {
    return SolveModel(
      solveId: json['solveId'],
      userId: json['userId'],
      solveTime: json['solveTime'],
      solveDate: DateTime.parse(json['solveDate']),
      method: json['method'],
      movesCount: json['movesCount'],
      solveResult: json['solveResult'],
      scramble: json['scramble'],
    );
  }
}

const String baseUrl = Constants.baseUrl;

Future<List<SolveModel>> fetchSolvesByUserId() async {
  final prefs = await SharedPreferences.getInstance();
  dynamic userInfoJson = prefs.getString('userInfo');
  dynamic userInfo = jsonDecode(userInfoJson!);
  print('userinfo');
  print(userInfo);
  int userId = userInfo['userId'];
  final response = await http.get(Uri.parse('$baseUrl/Solve/user/$userId'));
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    print('fetchsolve');
    print(jsonData);
    return jsonData.map((json) => SolveModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load solve data from api');
  }
}
