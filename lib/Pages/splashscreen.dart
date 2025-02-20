import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);

    // Start playing GIF on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gifController.animateBack(1);
      _gifController.repeat(min: 0, max: 30, period: const Duration(seconds: 3));
    });

    _navigateToHome();
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Twist and Solve!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 200, // Set width for better visibility
              height: 200,
              child: Gif(
                controller: _gifController,
                image: const AssetImage('assets/images/animated2dcube.gif'),
                fit: BoxFit.cover, // Ensure proper fitting
              ),
            ),
          ],
        ),
      ),
    );
  }
}
