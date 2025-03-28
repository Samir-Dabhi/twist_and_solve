import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/constants.dart';

const String baseUrl = Constants.baseUrl;


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


Future<List<SolveModel>> fetchSolvesByUserId() async {
  final prefs = await SharedPreferences.getInstance();

  // Retrieve user info and token
  String? userInfoJson = prefs.getString('userInfo');
  String? token = prefs.getString('token'); // Retrieve the token
  print(token);
  if (userInfoJson == null || token == null) {
    throw Exception('User info or token not found');
  }

  final userInfo = jsonDecode(userInfoJson);
  int userId = userInfo['userId'];

  // Set up headers with the token
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // Include the token in Authorization header
  };

  final response = await http.get(
    Uri.parse('$baseUrl/Solve/user/$userId'),
    headers: headers, // Pass headers in the request
  );
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => SolveModel.fromJson(json)).toList();
  }
  else if(response.statusCode == 404){
    throw Exception(response.body.toString());
  }
  else {
    throw Exception('Failed to load solve data from API');
  }
}

Future<void> removeSolveFromApi(int solveID) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Retrieve token

  if (token == null) {
    throw Exception('Token not found. Please log in again.');
  }

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // Attach JWT token
  };

  final response = await http.delete(
    Uri.parse('$baseUrl/Solve/$solveID'),
    headers: headers, // Pass headers
  );

  if (response.statusCode == 200) {
  } else {
    throw Exception('Failed to delete solve data! Status Code: ${response.statusCode}');
  }
}
class Stats{
  late SolveModel bestsolve;
  late double avrage;
  late double avrageof5;
  late double avrageof12;
  late SolveModel lastSolve;
}
Future<Stats> getSolveStats() async {
  List<SolveModel> list = await fetchSolvesByUserId();
  Stats stats = new Stats();
  double bestTime = list[0].solveTime;
  int bestIndex = 0;
  double sumOftime = 0;
  for(int i=0;i<list.length;i++){
    sumOftime+=list[i].solveTime;
    if(list[i].solveTime<bestTime){
      bestTime=list[i].solveTime;
      bestIndex=i;
    }
  }
  stats.bestsolve = list[bestIndex];
  stats.avrage = sumOftime/list.length;
  stats.lastSolve = list[list.length-1];

  if(list.length>5){
    sumOftime = 0;
    for(int i=list.length-1;i>list.length-5;i--){
      sumOftime+=list[i].solveTime;
      if(list[i].solveTime<bestTime){
        bestTime=list[i].solveTime;
        bestIndex=i;
      }
    }
    stats.avrageof5 = sumOftime/5;
  }
  else{
    stats.avrageof5=0;
  }
  if(list.length>12){
    sumOftime = 0;
    for(int i=list.length-1;i>list.length-12;i--){
      sumOftime+=list[i].solveTime;
      if(list[i].solveTime<bestTime){
        bestTime=list[i].solveTime;
        bestIndex=i;
      }
    }
    stats.avrageof12= sumOftime/12;
  }
  else{
    stats.avrageof12=0;
  }
  stats.avrageof12 ??= 0;
  return stats;
}