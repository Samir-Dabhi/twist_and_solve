import 'package:flutter/material.dart';
import 'package:twist_and_solve/Components/timer_component.dart';
import 'package:twist_and_solve/Pages/lession_list_page.dart';
import 'package:twist_and_solve/Pages/time_list_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text("Stop Watch"),
              SizedBox(width: 10,),
              Icon(Icons.timer)
            ],
          ),
        ),
        body: const TimerComponent(),
      ),
    );
  }
}
