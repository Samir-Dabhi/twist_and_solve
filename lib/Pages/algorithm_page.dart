import 'package:flutter/material.dart';
import 'package:twist_and_solve/Service/algorithm_service.dart';

class AlgorithmPage extends StatefulWidget {
  const AlgorithmPage({super.key});

  @override
  _AlgorithmPageState createState() => _AlgorithmPageState();
}

class _AlgorithmPageState extends State<AlgorithmPage> {
  late Future<List<Algorithm>> algorithms;

  @override
  void initState() {
    super.initState();
    algorithms = fetchAlgorithms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algorithms'),
      ),
      body: FutureBuilder<List<Algorithm>>(
        future: algorithms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final algorithm = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(algorithm.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notation: ${algorithm.notation}'),
                        if (algorithm.description != null)
                          Text('Description: ${algorithm.description}'),
                        if (algorithm.lessonId != null)
                          Text('Lesson ID: ${algorithm.lessonId}'),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No algorithms found'));
          }
        },
      ),
    );
  }
}