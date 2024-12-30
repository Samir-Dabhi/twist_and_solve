import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twist_and_solve/Pages/HomePage.dart';
import 'package:twist_and_solve/Pages/LessionListPage.dart';
import 'package:twist_and_solve/Pages/Login.dart';
import 'package:twist_and_solve/Pages/Progresspage.dart';
import 'package:twist_and_solve/Pages/Signup.dart';
import 'package:twist_and_solve/Pages/Splashscreen.dart';
import 'package:twist_and_solve/Pages/TimeListPage.dart';
import 'package:twist_and_solve/Service/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    final GoRouter router = GoRouter(
      initialLocation: '/splash', // Start with a splash screen
      redirect: (context, state) async {
        bool? isLoggedIn = await authService.getLoginStatusFromPrefs(); // Assuming this is async
        if(isLoggedIn==null){
          isLoggedIn=false;
        }
        final loggingIn = state.location == '/login' || state.location == '/signup';
        print('isLoggedIn=');
        print(isLoggedIn);
        if (!isLoggedIn! && !loggingIn) {
          return '/login'; // Redirect to login if not logged in
        }

        if (isLoggedIn && loggingIn) {
          return '/home'; // Redirect to home if logged in but on login/signup page
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(authService: authService),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => SignUpPage(authService: authService),
        ),
        GoRoute(
          path: '/splash',
          builder: (context, state) => SplashScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const Homepage(),
            ),
            GoRoute(
              path: '/timelist',
              builder: (context, state) => TimeList(),
            ),
            GoRoute(
              path: '/lessonlist',
              builder: (context, state) => const Lessionlistpage(),
            ),
            GoRoute(
              path: '/progress',
              builder: (context, state) => const Progresspage(),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Twist and Solve',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.account_circle_sharp),
        title: const Center(child: Text('Cube Trainer')),
        actions: const [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Icon(Icons.settings),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        currentIndex: _getCurrentIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/timelist');
              break;
            case 2:
              context.go('/lessonlist');
              break;
            case 3:
              context.go('/progress');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.black),
            label: 'Times',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection_rounded, color: Colors.black),
            label: 'Lessons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart, color: Colors.black),
            label: 'Progress',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouter.of(context).location;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/timelist')) return 1;
    if (location.startsWith('/lessonlist')) return 2;
    if (location.startsWith('/progress')) return 3;
    return 0; // Default to home if no match
  }
}
