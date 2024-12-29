import 'package:flutter/material.dart';
import 'package:twist_and_solve/Components/Timer.dart';
import 'package:twist_and_solve/Pages/LessionListPage.dart';
import 'package:twist_and_solve/Pages/TimeListPage.dart';

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
        body: const TimerComponent(),
      ),
    );
  }
}
