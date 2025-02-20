import 'package:flutter/material.dart';
import 'package:twist_and_solve/Service/algorithm_service.dart';

class AlgorithmDetailPage extends StatefulWidget {
  final String category;
  const AlgorithmDetailPage({super.key, required this.category});

  @override
  _AlgorithmDetailPageState createState() => _AlgorithmDetailPageState();
}

class _AlgorithmDetailPageState extends State<AlgorithmDetailPage> {
  late Future<List<Algorithm>> algorithms;

  @override
  void initState() {
    super.initState();
    algorithms = fetchAlgorithmsByCategory(widget.category.toUpperCase());
  }

  void _showAlgorithmDetails(Algorithm algorithm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    algorithm.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                if (algorithm.imageUrl != null)
                  Text('Notation: ${algorithm.notation}', style: const TextStyle(fontSize: 16)),
                if (algorithm.description != null) ...[
                  const SizedBox(height: 8),
                  Text('Description: ${algorithm.description}', style: const TextStyle(fontSize: 16)),
                ],
                if (algorithm.lessonId != null) ...[
                  const SizedBox(height: 8),
                  Text('Category : ${algorithm.category}', style: const TextStyle(fontSize: 16)),
                ],
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close',style: TextStyle(color: Colors.black54),),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} Algorithms')),
      body: FutureBuilder<List<Algorithm>>(
        future: algorithms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final algorithm = snapshot.data![index];

                  return GestureDetector(
                    onTap: () => _showAlgorithmDetails(algorithm),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: algorithm.imageUrl != null
                                ? ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                algorithm.imageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported, size: 50);
                                },
                              ),
                            )
                                : const Icon(Icons.image_not_supported, size: 50),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              algorithm.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('No algorithms found'));
          }
        },
      ),
    );
  }
}