import 'package:flutter/material.dart';

class CubeDisplay extends StatelessWidget {
  final List<List<List<String>>> cube;

  CubeDisplay({required this.cube});

  // Convert string color names to Flutter Colors
  Color getColor(String color) {
    switch (color.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'yellow':
        return Colors.yellow;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey; // fallback
    }
  }

  // Single 3x3 face widget
  Widget buildFace(List<List<String>> face) {
    return Column(
      children: face.map((row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: row.map((color) {
            return Container(
              height: 20,
              width: 20,
              margin: EdgeInsets.all(1),
              color: getColor(color),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Up face
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildFace(cube[4]),
                SizedBox(width: 70,)
              ],
            ),
            SizedBox(height: 4),
            // Left, Front, Right, Back faces
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                buildFace(cube[2]), // Right
                SizedBox(width: 4),
                buildFace(cube[3]), // Back
                SizedBox(width: 4),
                buildFace(cube[0]), // Left
                SizedBox(width: 4),
                buildFace(cube[1]), // Front
              ],
            ),
            SizedBox(height: 4),
            // Down face
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // buildFace(cube[3]), // Left
                // SizedBox(width: 4),
                // buildFace(cube[0]), // Front
                // SizedBox(width: 4),
                // buildFace(cube[1]), // Right
                // SizedBox(width: 4),// Spacer
                buildFace(cube[5]),
                SizedBox(width: 70,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
