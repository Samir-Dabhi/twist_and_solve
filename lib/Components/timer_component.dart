import 'dart:async';
import 'dart:convert';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:twist_and_solve/constants.dart';

import '../Service/user_achievement_service.dart';


class TimerComponent extends StatefulWidget {
  const TimerComponent({super.key});

  @override
  State<TimerComponent> createState() => _TimerComponentState();
}

class _TimerComponentState extends State<TimerComponent> {
  late ConfettiController _confettiController;
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isStoppedOnce = false;
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
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
    _confettiController.dispose();
    super.dispose();
  }

  void _showConfetti() {
    _confettiController.play();
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

  Future<void> _saveSolveTimeToDatabase(BuildContext context) async {
    const String apiUrl = '${Constants.baseUrl}/Solve'; // Replace with your API endpoint
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

        // Fetch achievement status
        Map<int, bool> achievementStatus = await fetchUserAchievementsStatus();

        // Check if the user hasn't earned achievement 1 yet
        if (achievementStatus[1] == false) {
          // Award the achievement
          await postUserAchievement(1);

          // 🎉 Show confetti animation
          _showConfetti();

          // 🏆 Show achievement popup
          _showAchievementPopup(context, "First Solve!", "Congratulations! You've earned your first solve achievement.");
        }
        if (achievementStatus[4] == false && solveTimeSeconds<30) {
          // Award the achievement
          await postUserAchievement(4);

          // 🎉 Show confetti animation
          _showConfetti();

          // 🏆 Show achievement popup
          _showAchievementPopup(context, "Sub 30!", "Congratulations! You've earned your Solve Cube under 30 second achievement.");
        }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final iconColor = theme.iconTheme.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
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
                      color: textColor,
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
                        await _saveSolveTimeToPrefs(formattedTime);
                        await _saveSolveTimeToDatabase(context);
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

          // 🎉 Confetti Widget added here!
          Positioned(
            bottom: 0, // Start from bottom
            left: 0,
            right: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -1.5 * 3.14, // Move from bottom to top
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              gravity: 0.1,
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.orange],
            ),
          ),
        ],
      ),
    );
  }

}
void _showAchievementPopup(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Center(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
