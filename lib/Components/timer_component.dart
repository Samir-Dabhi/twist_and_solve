import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class TimerComponent extends StatefulWidget {
  const TimerComponent({super.key});

  @override
  State<TimerComponent> createState() => _TimerComponentState();
}

class _TimerComponentState extends State<TimerComponent> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isStoppedOnce = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {}); // Update UI every 30ms
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the periodic timer
    super.dispose();
  }

  void _toggleStartStop() {
    if (_stopwatch.isRunning) {
      _isStoppedOnce = true;
      _stopwatch.stop();
    } else if (!_isStoppedOnce) {
      _stopwatch.start();
    }
  }

  void _resetTimer() {
    _isStoppedOnce = false;
    _stopwatch.reset();
  }

  Future<void> _saveSolveTimeToPrefs(String time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeList = prefs.getStringList('TimeList') ?? [];
    timeList.add(time);
    await prefs.setStringList('TimeList', timeList);
    debugPrint('Saved time locally: $time');
  }

  Future<void> _saveSolveTimeToDatabase() async {
    const String apiUrl = 'http://localhost:5167/Solve'; // Replace with your API endpoint
    try {
      final prefs = await SharedPreferences.getInstance();
      final userInfoJson = prefs.getString('userInfo');

      if (userInfoJson == null) {
        throw Exception('User not logged in.');
      }

      final userInfo = jsonDecode(userInfoJson) as Map<String, dynamic>;
      final solveTimeMilliseconds = _stopwatch.elapsed.inMilliseconds;
      final solveTimeSeconds = solveTimeMilliseconds / 1000;
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "solveId": 0,
          "userId": userInfo['userId'],
          "solveTime": solveTimeSeconds,
          "solveDate": DateTime.now().toIso8601String(),
          "method": "Beginner",
          "movesCount": 50,
          "solveResult": "Success",
          "scramble": "F R U R U F U R U R U R U2 R"
        }),
      );
      if (response.statusCode == 201) {
        debugPrint('Solve time saved to database successfully.');
      } else {
        debugPrint('Failed to save solve time: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error saving solve time: $e');
    }
  }

  String _getFormattedTime() {
    final milliseconds = _stopwatch.elapsed.inMilliseconds;
    final milli = (milliseconds % 100).toString().padLeft(2, "0");
    final seconds = ((milliseconds ~/ 1000) % 60).toString().padLeft(2, "0");
    final minutes = ((milliseconds ~/ 1000) ~/ 60).toString().padLeft(2, "0");
    return int.parse(minutes) > 0 ? "$minutes:$seconds:$milli" : "$seconds:$milli";
  }

  // Future<void> giveAchievement(String formattedTime) async {
  //   List<Achievement> earnedachievements = await fetchUserAchievements();
  //   List<bool> hasAchievement = [];
  //   earnedachievements.forEach((a) {
  //     if(a.title=='First Solve'){
  //       // TODO: post achievement when he earns it;
  //     }
  //     else if(a.title=='Speed Cuber'){
  //       return true;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // Access theme colors
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final iconColor = theme.iconTheme.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor, // Set background based on theme
      body: InkWell(
        onTap: _toggleStartStop,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display
            Container(
              height: 250,
              alignment: Alignment.center,
              child: Text(
                _getFormattedTime(),
                style: TextStyle(
                  color: textColor, // Dynamic text color
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Cancel Timer',
                ),
                IconButton(
                  onPressed: () async {
                    final formattedTime = _getFormattedTime();
                    await _saveSolveTimeToPrefs(formattedTime); // Save locally
                    await _saveSolveTimeToDatabase(); // Save to database
                    // await giveAchievement(formattedTime);
                  },
                  icon: const Icon(Icons.done, color: Colors.green),
                  tooltip: 'Save Solve',
                ),
                IconButton(
                  onPressed: _resetTimer,
                  icon: Icon(Icons.restore, color: iconColor),
                  tooltip: 'Restart Timer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
