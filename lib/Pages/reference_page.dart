import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class RubikCubePage extends StatefulWidget {
  const RubikCubePage({super.key});

  @override
  State<RubikCubePage> createState() => _RubikCubePageState();
}

class _RubikCubePageState extends State<RubikCubePage> {
  Flutter3DController controller = Flutter3DController();
  bool isPlaying = false;
  List<String> animations = [];

  @override
  void initState() {
    super.initState();
    controller.onModelLoaded.addListener(() async {
      debugPrint('Model is loaded: ${controller.onModelLoaded.value}');

      // Fetch available animations
      animations = await controller.getAvailableAnimations();
      debugPrint('Available Animations: $animations');
    });
  }

  void playAllAnimations() {
    if (animations.isEmpty) return;

    setState(() {
      isPlaying = true;
    });

    for (String animation in animations) {
      controller.playAnimation(animationName: animation);
    }
  }

  void stopAllAnimations() {
    if (animations.isEmpty) return;

    setState(() {
      isPlaying = false;
    });

    for (String animation in animations) {
      controller.pauseAnimation(); // Pauses all animations
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: const Center(
              child: Text("Comming Soon!!!!",style: TextStyle(fontSize: 18),),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: SizedBox(
                height: 400,
                child: Flutter3DViewer(
                  activeGestureInterceptor: true,
                  progressBarColor: Colors.orange,
                  enableTouch: true,
                  onProgress: (double progressValue) {
                    debugPrint('Model loading progress: $progressValue');
                  },
                  onLoad: (String modelAddress) {
                    debugPrint('Model loaded: $modelAddress');
                  },
                  onError: (String error) {
                    debugPrint('Model failed to load: $error');
                  },
                  controller: controller,
                  src: 'assets/models/cube1.glb',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
