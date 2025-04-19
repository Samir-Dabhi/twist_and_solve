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
  GlobalKey _widgetkey = GlobalKey();
  List<List<Color>> _detectedColors = List.generate(3, (_) => List.filled(3, Colors.grey));

  int imageWidth=0;
  int imageHeight=0;
  double diffX = 0;
  double diffY = 0;

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
    controller!.startImageStream((image) {
    imageWidth = image.width;
    imageHeight = image.height;
      final RenderBox renderBox = _widgetkey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      print('Width: ${size.width}, Height: ${size.height}');
      diffX=(imageWidth-size.width)/2;
      diffY=(imageHeight-size.height)/2;
      setState(() {});
      _processCameraImage(image);
    },);
    setState(() {});

  }

  List<List<Offset>> getGridSamplePoints(int width, int height) {
    final dx = width ~/ 6;
    final dy = height ~/ 6;
    print(dx);
    print(dy);
    List<List<Offset>> offsetList = [
      [Offset((imageWidth / 2)-(imageHeight/4),(imageHeight / 2)+(imageHeight/4)), Offset((imageWidth / 2)-(imageHeight/4),(imageHeight / 2)), Offset((imageWidth / 2)-(imageHeight/4),(imageHeight / 2)-(imageHeight/4))],
      [Offset((imageWidth / 2),(imageHeight / 2)+(imageHeight/4)), Offset((imageWidth / 2),(imageHeight / 2)), Offset((imageWidth / 2),(imageHeight / 2)-(imageHeight/4))],
      [Offset((imageWidth / 2)+(imageHeight/4),(imageHeight / 2)+(imageHeight/4)), Offset((imageWidth / 2)+(imageHeight/4),(imageHeight / 2)), Offset((imageWidth / 2)+(imageHeight/4),(imageHeight / 2)-(imageHeight/4))],
    ];
    return offsetList;
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
        final colorName = getColorNameFromHSV(rgb[0], rgb[1], rgb[2]);

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

  Map<String, double> rgbToHsv(int r, int g, int b) {
    double rf = r / 255;
    double gf = g / 255;
    double bf = b / 255;

    double max = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    double min = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
    double delta = max - min;

    double h = 0;
    if (delta != 0) {
      if (max == rf) {
        h = 60 * (((gf - bf) / delta) % 6);
      } else if (max == gf) {
        h = 60 * (((bf - rf) / delta) + 2);
      } else if (max == bf) {
        h = 60 * (((rf - gf) / delta) + 4);
      }
    }

    if (h < 0) h += 360;

    double s = max == 0 ? 0 : delta / max;
    double v = max;

    return {
      'h': h,     // Hue in degrees (0 - 360)
      's': s,     // Saturation (0 - 1)
      'v': v,     // Value (0 - 1)
    };
  }

  String getColorNameFromHSV(int r, int g, int b) {
    final hsv = rgbToHsv(r, g, b);
    final h = hsv['h']!;
    final s = hsv['s']!;
    final v = hsv['v']!;

    if (v < 0.2) return "Black";
    if (s < 0.15 && v > 0.85) return "White";
    if (s < 0.15) return "White";

    if (h < 20 || h >= 340) return "Red";
    if (h >= 20 && h < 50) return "Orange";
    if (h >= 50 && h < 70) return "Yellow";
    if (h >= 70 && h < 170) return "Green";
    if (h >= 170 && h < 260) return "Blue";
    if (h >= 260 && h < 320) return "Purple";

    return "Unknown";
  }


  // String getColorName(int r, int g, int b) {
  //   // Define typical RGB values for Rubik's Cube colors
  //   const Map<String, List<int>> knownColors = {
  //     'Red': [200, 30, 30],
  //     'Green': [30, 200, 30],
  //     'Blue': [30, 30, 200],
  //     'Yellow': [255, 255, 0],
  //     'White': [250, 250, 250],
  //     'Orange': [255, 140, 0],
  //     'Black': [0, 0, 0],
  //   };
  //
  //   double minDistance = double.infinity;
  //   String closestColor = 'Unknown';
  //
  //   for (var entry in knownColors.entries) {
  //     final kr = entry.value[0];
  //     final kg = entry.value[1];
  //     final kb = entry.value[2];
  //
  //     double distance = ((r - kr) * (r - kr) +
  //         (g - kg) * (g - kg) +
  //         (b - kb) * (b - kb)).toDouble();
  //
  //     if (distance < minDistance) {
  //       minDistance = distance;
  //       closestColor = entry.key;
  //     }
  //   }
  //
  //   return closestColor;
  // }


  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Camera Page")),
      body: Stack(
        key: _widgetkey,
        children: [
          Center(child: CameraPreview(controller!)),
           _buildOverlayGrid(),
        ],
      ),
    );
  }
  Widget _buildOverlayGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top black space
        Expanded(
          child: Container(
            color: Colors.white,
          ),
        ),

        // The grid itself
        AspectRatio(
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
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Center(
                              child: Container(
                                height: 20,
                                width: 20,
                                color: _detectedColors[row][col],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
              ],
            );
          }),
        ),

        // Bottom black space
        Expanded(
          child: Container(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

}