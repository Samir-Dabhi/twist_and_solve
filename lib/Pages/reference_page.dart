import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class RubikCubePage extends StatefulWidget {
  const RubikCubePage({super.key});

  @override
  State<RubikCubePage> createState() => _RubikCubePageState();
}

class _RubikCubePageState extends State<RubikCubePage> {
  Flutter3DController controller = Flutter3DController();
  late bool isPlay;
  @override
  @override
  void initState() {
    isPlay = false;
    // TODO: implement initState
    super.initState();
    controller.onModelLoaded.addListener(() async {
      debugPrint('model is loaded : ${controller.onModelLoaded.value}');
      List<String> str = await controller.getAvailableAnimations();
      str.forEach(print);
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D cube"),
      ),
      body: Center(
        child: SizedBox(
          height: 400,
            child: //The 3D viewer widget for obj format
            //The 3D viewer widget for glb and gltf format
            Flutter3DViewer(
              //If you pass 'true' the flutter_3d_controller will add gesture interceptor layer
              //to prevent gesture recognizers from malfunctioning on iOS and some Android devices.
              //the default value is true
              activeGestureInterceptor: true,
              //If you don't pass progressBarColor, the color of defaultLoadingProgressBar will be grey.
              //You can set your custom color or use [Colors.transparent] for hiding loadingProgressBar.
              progressBarColor: Colors.orange,
              //You can disable viewer touch response by setting 'enableTouch' to 'false'
              enableTouch: true,
              //This callBack will return the loading progress value between 0 and 1.0
              onProgress: (double progressValue) {
                debugPrint('model loading progress : $progressValue');
              },
              //This callBack will call after model loaded successfully and will return model address
              onLoad: (String modelAddress) {
                debugPrint('model loaded : $modelAddress');
              },
              //this callBack will call when model failed to load and will return failure error
              onError: (String error) {
                debugPrint('model failed to load : $error');
              },
              //You can have full control of 3d model animations, textures and camera
              controller: controller,
              //src: 'assets/business_man.glb', //3D model with different animations
              //src: 'assets/sheen_chair.glb', //3D model with different textures
              src: 'assets/models/cube1.glb', // 3D model from URL
            )
        ),
      ),
      floatingActionButton: IconButton(onPressed: () async {
        // setState(() {
        //
        // });
        // isPlay=!isPlay;
        // isPlay? {
          controller.playAnimation(animationName:"BrAction");
        // }:controller.pauseAnimation();
      }, icon: isPlay?const Icon(Icons.pause):const Icon(Icons.play_arrow)),
    );
  }
}


























// available animations
//Sketchfab_modelAction
// Rubik.fbxAction
// RootNodeAction
// RootAction
// RubikAction
// 1Action
// 1_Black_0Action
// 1_Blue_0Action
// 1_Orange_0Action
// 1_Yellow_0Action
// 10Action
// 10_Black_0Action
// 10_Red_0Action
// 10_White_0Action
// 11Action
// 11_Black_0Action
// 11_Green_0Action
// 11_Red_0Action
// 11_White_0Action
// 12Action
// 12_Black_0Action
// 12_Blue_0Action
// 12_Orange_0Action
// 12_White_0Action
// 13Action
// 13_Black_0Action
// 13_Orange_0Action
// 13_White_0Action
// 14Action
// 14_Black_0Action
// 14_Green_0Action
// 14_Orange_0Action
// 14_White_0Action
// 15Action
// 15_Black_0Action
// 15_Blue_0Action
// 15_White_0Action
// 16Action
// 16_Black_0Action
// 16_Blue_0Action
// 17Action
// 17_Black_0Action
// 17_Blue_0Action
// 17_Red_0Action
// 17_White_0Action
// 18Action
// 18_Black_0Action
// 18_Green_0Action
// 18_White_0Action
// 19Action
// 19_Black_0Action
// 19_White_0Action
// 2Action
// 2_Black_0Action
// 2_Orange_0Action
// 2_Yellow_0Action
// 20Action
// 20_Black_0Action
// 20_Red_0Action
// 21Action
// 21_Black_0Action
// 21_Green_0Action
// 22Action
// 22_Black_0Action
// 22_Orange_0Action
// 23Action
// 23_Black_0Action
// 23_Blue_0Action
// 23_Red_0Action
// 24Action
// 24_Black_0Action
// 24_Blue_0Action
// 24_Orange_0Action
// 25Action
// 25_Black_0Action
// 25_Green_0Action
// 25_Red_0Action
// 26Action
// 26_Black_0Action
// 26_Green_0Action
// 26_Orange_0Action
// 3Action
// 3_Black_0Action
// 3_Green_0Action
// 3_Orange_0Action
// 3_Yellow_0Action
// 4Action
// 4_Black_0Action
// 4_Blue_0Action
// 4_Yellow_0Action
// 5Action
// 5_Black_0Action
// 5_Green_0Action
// 5_Yellow_0Action
// 6Action
// 6_Black_0Action
// 6_Green_0Action
// 6_Red_0Action
// 6_Yellow_0Action
// 7Action
// 7_Black_0Action
// 7_Blue_0Action
// 7_Red_0Action
// 7_Yellow_0Action
// 8Action
// 8_Black_0Action
// 8_Red_0Action
// 8_Yellow_0Action
// 9Action
// 9_Black_0Action
// 9_Yellow_0Action
// Rubik_Material.001_0Action
// CubeAction
