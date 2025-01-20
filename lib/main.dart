import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/Components/SettingPanel.dart';
import 'package:twist_and_solve/Pages/HomePage.dart';
import 'package:twist_and_solve/Pages/LessionListPage.dart';
import 'package:twist_and_solve/Pages/Login.dart';
import 'package:twist_and_solve/Pages/Progresspage.dart';
import 'package:twist_and_solve/Pages/Signup.dart';
import 'package:twist_and_solve/Pages/Splashscreen.dart';
import 'package:twist_and_solve/Pages/TimeListPage.dart';
import 'package:twist_and_solve/Pages/VideoListPage.dart';
import 'package:twist_and_solve/Pages/VideoPlayerScreen.dart';
import 'package:twist_and_solve/Service/auth_service.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // Track dark mode state

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    final GoRouter router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) async {
        bool? isLoggedIn = await authService.getLoginStatusFromPrefs();
        final loggingIn = state.location == '/login' || state.location == '/signup';
        if (!isLoggedIn && !loggingIn) {
          return '/login';
        }

        if (isLoggedIn && loggingIn) {
          return '/home';
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
            return MainScaffold(
              isDarkMode: _isDarkMode,
              onThemeChanged: (bool value) {
                setState(() {
                  _isDarkMode = value; // Update dark mode state
                });
              },
              child: child,
            );
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
              builder: (context, state) => const LessonListPage(),
            ),
            GoRoute(
              path: '/videos/:lessonId',
              builder: (context, state) {
                final lessonId = int.parse(state.params['lessonId']!);
                return VideoListPage(lessonId: lessonId);
              },
            ),
            GoRoute(
              path: '/videoPlayer',
              builder: (context, state) {
                final videoUrl = Uri.decodeComponent(state.queryParams['videoUrl']!);
                final videoName = Uri.decodeComponent(state.queryParams['videoName']!);

                return VideoPlayerScreen(
                  videoUrl: videoUrl,
                  videoName: videoName,
                );
              },
            ),
            GoRoute(
              path: '/progress',
              builder: (context, state) {
                return const ProgressPage();
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Twist and Solve',
      routerConfig: router,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}


class MainScaffold extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainScaffold({
    required this.child,
    required this.isDarkMode,
    required this.onThemeChanged,
    super.key,
  });

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  Future<Map<String, dynamic>?>? _userInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = AuthService.getUserInfo(); // Fetch user info when the widget initializes
  }

  Future<void> _logout() async {
    // Call your logout method here
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear user data
    if (mounted) {
      context.go('/login'); // Navigate to login page after logout
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.account_circle_sharp),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Center(child: Text('Cube Trainer')),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return SettingsPanel(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    );
                  },
                );
              },
              child: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _userInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return ListView(
                children: const [
                  DrawerHeader(
                    child: Text('Error loading user info'),
                  ),
                ],
              );
            }

            final userInfo = snapshot.data!;
            final userName = userInfo['username'] ?? 'Unknown User';
            final email = userInfo['email'] ?? 'Unknown Email';
            // final profilePicture = userInfo['profilePicture'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3lUQuZFpHuUdWxWi42QcoXzzWyi86wxiblYw3v682ce-2ioFrwXZaMPBNRovR6RY_iWM&usqp=CAU';
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(userName),
                  accountEmail: Text(email),
                  currentAccountPicture: const CircleAvatar(
                    child: Icon(Icons.account_circle, size: 50),
                    /// TDOD fetch image from image.network

                    // child: Image.network(profilePicture),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    context.go('/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Times'),
                  onTap: () {
                    context.go('/timelist');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_collection_rounded),
                  title: const Text('Lessons'),
                  onTap: () {
                    context.go('/lessonlist');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.show_chart),
                  title: const Text('Progress'),
                  onTap: () {
                    context.go('/progress');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: _logout, // Call the logout method
                ),
              ],
            );
          },
        ),
      ),
      body: widget.child,
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



