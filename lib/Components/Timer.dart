import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TimerComponent extends StatefulWidget {
  const TimerComponent({Key? key}) : super(key: key);

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
    // Update the timer UI every 30ms
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {}); // Ensure the widget is mounted before updating
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the periodic timer to avoid memory leaks
    super.dispose();
  }

  /// Toggles between start and stop of the stopwatch
  void _toggleStartStop() {
    if (_stopwatch.isRunning) {
      _isStoppedOnce = true;
      _stopwatch.stop();
    } else if (!_isStoppedOnce) {
      _stopwatch.start();
    }
  }

  /// Resets the timer and its state
  void _resetTimer() {
    _isStoppedOnce = false;
    _stopwatch.reset();
  }

  /// Saves the solve time to shared preferences
  Future<void> _saveSolveTimeToPrefs(String time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeList = prefs.getStringList('TimeList') ?? [];
    timeList.add(time);
    await prefs.setStringList('TimeList', timeList);
    debugPrint('Saved time locally: $time');
  }

  /// Saves the solve time to the database
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
      print(response);
      if (response.statusCode == 201) {
        debugPrint('Solve time saved to database successfully.');
      } else {
        debugPrint('Failed to save solve time: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error saving solve time: $e');
    }
  }

  /// Returns the formatted timer text
  String _getFormattedTime() {
    final milliseconds = _stopwatch.elapsed.inMilliseconds;

    final milli = (milliseconds % 100).toString().padLeft(2, "0");
    final seconds = ((milliseconds ~/ 1000) % 60).toString().padLeft(2, "0");
    final minutes = ((milliseconds ~/ 1000) ~/ 60).toString().padLeft(2, "0");

    return int.parse(minutes) > 0 ? "$minutes:$seconds:$milli" : "$seconds:$milli";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                style: const TextStyle(
                  color: Colors.black,
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
                  tooltip: 'Reset Timer',
                ),
                IconButton(
                  onPressed: () async {
                    final formattedTime = _getFormattedTime();
                    await _saveSolveTimeToPrefs(formattedTime); // Save locally
                    await _saveSolveTimeToDatabase(); // Save to database
                  },
                  icon: const Icon(Icons.done, color: Colors.green),
                  tooltip: 'Save Solve',
                ),
                IconButton(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.restore, color: Colors.blue),
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
