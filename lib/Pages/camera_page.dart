import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:twist_and_solve/Components/cube_display_widget.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  final GlobalKey _widgetkey = GlobalKey();
  final List<List<Color>> _detectedColors = List.generate(3, (_) => List.filled(3, Colors.grey));
  final List<List<List<String>>> cube_color_state = List.generate(6, (_) => List.generate(3, (_)=>List.filled(3, "Grey")));
  int faceNumber=1;
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
    diffX=(imageWidth-size.width)/2;
    diffY=(imageHeight-size.height)/2;
    _processCameraImage(image);
    },);
    setState(() {});

  }

  List<List<Offset>> getGridSamplePoints(int width, int height) {
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

    if ((h >= 0 && h < 15) || h >= 345) return "Red";
    if (h >= 15 && h < 40) return "Orange";
    if (h >= 40 && h < 80) return "Yellow";    // widened yellow
    if (h >= 80 && h < 160) return "Green";    // tightened green
    if (h >= 160 && h < 260) return "Blue";
    if (h >= 260 && h < 320) return "Purple";

    return "Unknown";
  }

  List<List<Color>> convertColorNamesToColors(List<List<String>> colorNames) {
    // Define a mapping from color name to actual Color
    final Map<String, Color> colorMap = {
      'Red': Colors.red,
      'Orange': Colors.orange,
      'Yellow': Colors.yellow,
      'Green': Colors.green,
      'Blue': Colors.blue,
      'White': Colors.white,
    };

    return colorNames.map((row) {
      return row.map((name) {
        return colorMap[name] ?? Colors.grey; // fallback to grey if unknown
      }).toList();
    }).toList();
  }

  void SaveCubeState(final List<List<Color>> detectedColors,int faceNumber){
    List<List<String>> face = [];
    for(int i=0;i<detectedColors.length;i++){
      List<String> row = [];
      for(int j=0;j<detectedColors[i].length;j++){
        Color color = detectedColors[i][j]; // Example color

        int red = color.red;
        int green = color.green;
        int blue = color.blue;
        String colorstr = getColorNameFromHSV(red, green, blue);
        row.add(colorstr);
      }
      face.add(row);
    }
    String centerColor = face[1][1];
    if (centerColor == "White" && faceNumber == 1) {
      cube_color_state[0] = face;
    } else if (centerColor == "Red" && faceNumber == 2) {
      cube_color_state[1] = face;
    } else if (centerColor == "Yellow" && faceNumber == 3) {
      cube_color_state[2] = face;
    } else if (centerColor == "Orange" && faceNumber == 4) {
      cube_color_state[3] = face;
    } else if (centerColor == "Blue" && faceNumber == 5) {
      cube_color_state[4] = face;
    } else if (centerColor == "Green" && faceNumber == 6) {
      cube_color_state[5] = face;
    } else {
      print("Please scan the correct face for center color: $centerColor");
    }
    List<List<Color>> faceWithColor = convertColorNamesToColors(face);
    _showBottomColorGridPopup(context, faceWithColor);
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
      body: Stack(
        key: _widgetkey,
        children: [
          Center(child: CameraPreview(controller!)),
           _buildOverlayGrid(faceNumber),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: IconButton(onPressed: (){
                //SaveState
                print(_detectedColors.toString()+"==========================================");
                SaveCubeState(_detectedColors,faceNumber);
                faceNumber++;
                if(faceNumber==7){
                  context.push('/cube', extra: cube_color_state);
                }
              },
              icon: const Expanded(
                  child: Icon(Icons.camera,size: 60,)
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOverlayGrid(int faceNumber) {
    String centerColor = "";
    String otherColor = "";
    switch (faceNumber) {
      case 1:
        centerColor = "White";
        otherColor = "Blue";
        break;
      case 2:
        centerColor = "Red";
        otherColor = "Blue";
        break;
      case 3:
        centerColor = "Yellow";
        otherColor = "Blue";
        break;
      case 4:
        centerColor = "Orange";
        otherColor = "Blue";
        break;
      case 5:
        centerColor = "Blue";
        otherColor = "Red";
        break;
      case 6:
        centerColor = "Green";
        otherColor = "Orange";
        break;
      default:

    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top black space
        Expanded(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: Center(child: Text("${centerColor} Center should face camara \n and ${otherColor} center on the top")),
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
  void _showBottomColorGridPopup(BuildContext context, List<List<Color>> gridColors) {
    int selectedRow = -1;
    int selectedCol = -1;
    List<bool> selectColor = [false,false,false,false,false,false];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: (){
                  selectedRow=-1;
                  selectedCol = -1;
                  selectColor = [false,false,false,false,false,false];
                  setState((){});
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Detected Colors (3x3)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: List.generate(3, (row) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (col) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedRow = row;
                                  selectedCol = col;
                                  if(selectColor.contains(true)){
                                    gridColors[row][col] = mapedColor(selectColor);
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: gridColors[row][col],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: (selectedRow == row && selectedCol == col)
                                        ? Colors.blue
                                        : Colors.black,
                                    width: 5,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),//3X3 grid
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(onTap: (){
                          selectColor = [false,false,false,false,false,false];
                          selectColor[0]=true;
                          if(selectedRow>=0 && selectedCol>=0){
                            gridColors[selectedRow][selectedCol] = Colors.red;
                          }
                            setState((){});
                        },child: _buildCircle(Colors.red,selectColor[0])),
                        SizedBox(width: 10),
                        InkWell(onTap: (){
                          selectColor = [false,false,false,false,false,false];
                          selectColor[1]=true;
                          if(selectedRow>=0 && selectedCol>=0){
                            gridColors[selectedRow][selectedCol] = Colors.blue;
                          }
                            setState((){});
                        },child: _buildCircle(Colors.blue,selectColor[1])),
                        SizedBox(width: 10),
                        InkWell(onTap: (){
                          selectColor = [false,false,false,false,false,false];
                          selectColor[2]=true;
                          if(selectedRow>=0 && selectedCol>=0){
                            gridColors[selectedRow][selectedCol] = Colors.white;
                          }
                            setState((){});
                        },child: _buildCircle(Colors.white,selectColor[2])),
                        SizedBox(width: 10),
                        InkWell(onTap: (){
                          selectColor = [false,false,false,false,false,false];
                          selectColor[3]=true;
                          if(selectedRow>=0 && selectedCol>=0){
                            gridColors[selectedRow][selectedCol] = Colors.orange;
                          }
                            setState((){});
                        },child: _buildCircle(Colors.orange,selectColor[3])),
                        SizedBox(width: 10),
                        InkWell(onTap: (){
                          selectColor = [false,false,false,false,false,false];
                          selectColor[4]=true;
                          if(selectedRow>=0 && selectedCol>=0){
                            gridColors[selectedRow][selectedCol] = Colors.green;
                          }
                            setState((){});
                        },child: _buildCircle(Colors.green,selectColor[4])),
                        SizedBox(width: 10),
                        InkWell(onTap: (){
                          selectColor = [false,false,false,false,false,false];
                          selectColor[5]=true;
                          if(selectedRow>=0 && selectedCol>=0){
                            gridColors[selectedRow][selectedCol] = Colors.yellow;
                          }
                            setState((){});
                        },child: _buildCircle(Colors.yellow,selectColor[5])),
                      ],
                    ),//color select
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {

                        return Navigator.pop(context);
                      },
                      child: const Text(
                        'Ok',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  Color mapedColor(List<bool> SelectedColor){
    if(SelectedColor[0]){
      return Colors.red;
    }
    else if(SelectedColor[1]){
      return Colors.blue;
    }
    else if(SelectedColor[2]){
      return Colors.white;
    }
    else if(SelectedColor[3]){
      return Colors.orange;
    }
    else if(SelectedColor[4]){
      return Colors.green;
    }
    else if(SelectedColor[5]){
      return Colors.yellow;
    }
    else{
      return Colors.grey;
    }
  }
  Widget _buildCircle(Color color,bool selected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: (!selected)?Colors.black:Colors.blue, width: 2),
      ),
    );
  }

}
