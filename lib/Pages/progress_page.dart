import 'package:flutter/material.dart';
import 'package:twist_and_solve/Components/ProgressGraph.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProgressGraph(),
    );
  }
}
