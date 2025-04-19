import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  List<List<Color>> _detectedColors = List.generate(3, (_) => List.filled(3, Colors.grey));

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }


  Future<void> initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller!.initialize();
    controller!.startImageStream(_processCameraImage);
    setState(() {});

  }

  List<List<Offset>> getGridSamplePoints(int width, int height) {
    final dx = width ~/ 6;
    final dy = height ~/ 6;
    print(dx);
    print(dy);
    return List.generate(3, (i) =>
        List.generate(3, (j) => Offset((j * 2 + 1) * dx.toDouble(), (i * 2 + 1) * dy.toDouble()))
    );
  }

  void _processCameraImage(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final points = getGridSamplePoints(width, height);
    print(points.toString()+"points");
    final result = <String>[];

    for (int i = 0; i < points.length; i++) {
      for (int j = 0; j < points[i].length; j++) {
        final point = points[i][j];
        final rgb = getAverageRGBAtImage(convertYUV420ToImage(image), point.dx.toInt(), point.dy.toInt());
        final colorName = getColorName(rgb[0], rgb[1], rgb[2]);

        // Update the detected color at the current grid point
        _detectedColors[i][j] = Color.fromRGBO(rgb[0], rgb[1], rgb[2], 0.8);

        result.add(colorName);
      }
    }

    print("3x3 Grid Colors:\n${result.join(", ")}");

    // Optionally, call setState here if you want to immediately update the UI
    setState(() {});
  }


  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image image = img.Image(width, height);

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);

        final int yp = cameraImage.planes[0].bytes[y * cameraImage.planes[0].bytesPerRow + x];
        final int up = cameraImage.planes[1].bytes[uvIndex];
        final int vp = cameraImage.planes[2].bytes[uvIndex];

        int r = (yp + 1.370705 * (vp - 128)).round().clamp(0, 255);
        int g = (yp - 0.698001 * (vp - 128) - 0.337633 * (up - 128)).round().clamp(0, 255);
        int b = (yp + 1.732446 * (up - 128)).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b);
      }
    }

    return image;
  }

  List<int> getAverageRGBAtImage(img.Image image, int cx, int cy, [int size = 3]) {
    int r = 0, g = 0, b = 0, count = 0;
    int half = size ~/ 2;

    for (int dy = -half; dy <= half; dy++) {
      for (int dx = -half; dx <= half; dx++) {
        int x = (cx + dx).clamp(0, image.width - 1);
        int y = (cy + dy).clamp(0, image.height - 1);

        final pixel = image.getPixel(x, y);
        r += img.getRed(pixel);
        g += img.getGreen(pixel);
        b += img.getBlue(pixel);
        count++;
      }
    }

    return [r ~/ count, g ~/ count, b ~/ count];
  }


  String getColorName(int r, int g, int b) {
    // Dominant red
    if (r > 150 && r > g + 50 && r > b + 50) return "Red";
    // Dominant green
    if (g > 150 && g > r + 50 && g > b + 50) return "Green";
    // Dominant blue
    if (b > 150 && b > r + 50 && b > g + 50) return "Blue";
    // Yellow = high red + green, low blue
    if (r > 150 && g > 150 && b < 100) return "Yellow";
    // White = all high
    if (r > 180 && g > 180 && b > 180) return "White";
    // Black = all low
    if (r < 50 && g < 50 && b < 50) return "Black";

    return "Unknown";
  }

  Color _mapColorNameToColor(String name) {
    switch (name) {
      case 'Red': return Colors.red;
      case 'Green': return Colors.green;
      case 'Blue': return Colors.blue;
      case 'Yellow': return Colors.yellow;
      case 'White': return Colors.white;
      case 'Black': return Colors.black;
      default: return Colors.grey;
    }
  }



  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Camera Page")),
      body: Container(
        color: Colors.black,
        child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 1, // Square
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      maxHeight: double.infinity,
                      maxWidth: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller!.value.previewSize!.height,
                          height: controller!.value.previewSize!.width,
                          child: CameraPreview(controller!),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(child: _buildOverlayGrid()),
              LayoutBuilder(
                builder: (context, constraints) {
                  final points = getGridSamplePoints(
                    constraints.maxWidth.toInt(),
                    constraints.maxHeight.toInt(),
                  );

                  return Stack(
                    children: points.expand((row) => row).map((point) {
                      return Positioned(
                        left: point.dx - 5,
                        top: point.dy - 5,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 0, 0, 1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final file = await controller!.takePicture();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Picture saved: ${file.path}"),
          ));
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
  Widget _buildOverlayGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, constraints) {
        final cellSize = constraints.maxWidth / 3;
        return Stack(
          children: [
            for (int row = 0; row < 3; row++)
              for (int col = 0; col < 3; col++)
                Positioned(
                  left: col * cellSize,
                  top: row * cellSize,
                  width: cellSize,
                  height: cellSize,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _detectedColors[row][col],
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                      Center(
                        child: Text(row.toString()+" "+col.toString())
                      ),
                    ],
                  ),

                )
          ],
        );
      }),
    );
  }
}
