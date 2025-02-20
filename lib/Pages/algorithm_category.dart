import 'package:flutter/material.dart';
import 'package:twist_and_solve/Pages/algorithm_page.dart';

class AlgorithmCategoriesPage extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'name': 'OLL', 'icon': Icons.auto_fix_high},
    {'name': 'PLL', 'icon': Icons.shuffle},
    {'name': 'F2L', 'icon': Icons.layers},
    {'name': 'Cross', 'icon': Icons.grid_on},
    {'name': 'Advanced', 'icon': Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Algorithm Categories')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlgorithmDetailPage(category: categories[index]['name']),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(categories[index]['icon'], size: 50, color: Colors.blue),
                    const SizedBox(height: 10),
                    Text(
                      categories[index]['name'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


