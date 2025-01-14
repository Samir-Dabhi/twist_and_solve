import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/Pages/TimeListPage.dart';
var timeListglobel = [];

class TimerComponent extends StatefulWidget {
  const TimerComponent({super.key});
  @override
  State<TimerComponent> createState() => _TimerComponentState();
}

class _TimerComponentState extends State<TimerComponent> {

  late Stopwatch stopwatch;
  Stopwatch newstopwatch = Stopwatch();
  late Timer t;
  bool isStopedOnce = false;
  var timeList = [];
  void handleStartStop() {
    if(stopwatch.isRunning) {
      isStopedOnce = true;
      stopwatch.stop();
    }
    else if(!isStopedOnce) {
      stopwatch.start();
    }
  }

  List returnTimerList(){
    return timeList;
  }

  Future<void> setPreference(String time) async {
    print('add time list called'+time);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list;
    if(prefs.getStringList('TimeList')==null){
      prefs.setStringList("TimeList", List.empty());
    }
    list = prefs.getStringList('TimeList');
    list?.add(time);
    prefs.setStringList('TimeList', list!);
  }

  String returnFormattedText() {
    var milli = stopwatch.elapsed.inMilliseconds;

    String milliseconds = (milli % 100).toString().padLeft(2, "0"); // this one for the miliseconds
    String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0"); // this is for the second
    String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0"); // this is for the minute

    if(int.parse(minutes)>0){
      return "$minutes:$seconds:$milliseconds";
    }
    return "$seconds:$milliseconds";
  }
  // bool addSolveToApi(){
  //
  // }
  void resetTimer(){
    isStopedOnce = false;
    stopwatch.reset();
  }

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();

    t = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: (){
          handleStartStop();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 250,
              alignment: Alignment.center,
              child: Text(returnFormattedText(), style: const TextStyle(
                color: Colors.black,
                fontSize: 70,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () {
                  resetTimer();
                }, icon: const Icon(Icons.close)),
                IconButton(onPressed: () {
                  setPreference(returnFormattedText());
                  //TODO: api call for add solve here
                }, icon: const Icon(Icons.done)),
                IconButton(onPressed: () {
                  resetTimer();
                }, icon: const Icon(Icons.restore)),
              ],
            )
          ],
        ),
      ),
    );
  }
}