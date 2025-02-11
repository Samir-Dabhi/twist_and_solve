import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class RubiksCubePage extends StatefulWidget {

  const RubiksCubePage({super.key});

  @override
  State<RubiksCubePage> createState() => _RubiksCubePageState();
}

class _RubiksCubePageState extends State<RubiksCubePage> {
  Flutter3DController controller = Flutter3DController();

  String? chosenAnimation;
  String? chosenTexture;
  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() {
      debugPrint('model is loaded : ${controller.onModelLoaded.value}');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Object Display'),
      ),
      body: //The 3D viewer widget for obj format
      Flutter3DViewer.obj(
        src: 'assets/flutter_dash.obj',
        //src: 'https://raw.githubusercontent.com/m-r-davari/content-holder/refs/heads/master/flutter_3d_controller/flutter_dash_model/flutter_dash.obj',
        scale: 5,
        // Initial scale of obj model
        cameraX: 0,
        // Initial cameraX position of obj model
        cameraY: 0,
        //Initial cameraY position of obj model
        cameraZ: 10,
        //Initial cameraZ position of obj model
        //This callBack will return the loading progress value between 0 and 1.0
        onProgress: (double progressValue) {
          debugPrint('model loading progress : $progressValue');
        },
        //This callBack will call after model loaded successfully and will return model address
        onLoad: (String modelAddress) {
          debugPrint('model loaded : $modelAddress');
        },
        //this callBack will call when model failed to load and will return failure erro
        onError: (String error) {
          debugPrint('model failed to load : $error');
        },
      ),
      bottomNavigationBar:
         IconButton(onPressed: (){
           // controller.playAnimation();
         }, icon: const Icon(Icons.play_arrow)),
    );
  }
}

