import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  int userId = userInfo['userId'];
  final response = await http.get(Uri.parse('$baseUrl/Solve/user/$userId'));
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((json) => SolveModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load solve data from api');
  }
}
Future<void> removeSolveFromApi(int solveID) async {
  final response = await http.delete(Uri.parse('$baseUrl/Solve/$solveID'));
  if (response.statusCode == 200) {

  } else {
    throw Exception('Failed to delete solve data!');
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