import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twist_and_solve/Components/setting_component.dart';
import 'package:twist_and_solve/Pages/algorithm_category.dart';
import 'package:twist_and_solve/Pages/algorithm_page.dart';
import 'package:twist_and_solve/Pages/send_otp.dart';
import 'package:twist_and_solve/Pages/home_page.dart';
import 'package:twist_and_solve/Pages/lession_list_page.dart';
import 'package:twist_and_solve/Pages/login.dart';
import 'package:twist_and_solve/Pages/progress_page.dart';
import 'package:twist_and_solve/Pages/reference_page.dart';
import 'package:twist_and_solve/Pages/signup.dart';
import 'package:twist_and_solve/Pages/splashscreen.dart';
import 'package:twist_and_solve/Pages/time_list_page.dart';
import 'package:twist_and_solve/Pages/video_list_page.dart';
import 'package:twist_and_solve/Pages/video_player_screen.dart';
import 'package:twist_and_solve/Pages/achivement_page.dart';
import 'package:twist_and_solve/Service/auth_service.dart';

import 'Pages/video_player.dart';


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
  Color primaryColor = const Color(0xFFCBF1F5);
  Color backgroundColor = const Color(0xFFF9F7F7);
  Color highlightColor = const Color(0xFFA6E3E9);
  Color darkHighLightColor = const Color(0xFF112D4E);
  Color darkPrimaryColor = const Color(0xFF393E46);
  Color darkBackgroundColor = const Color(0xFF222831);
  Color darkHighlightColor = const Color(0xFF00ADB5);
  Color darkDarkHighLightColor = const Color(0xFFEEEEEE);
  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    final GoRouter router = GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) async {
        bool? isLoggedIn = await authService.getLoginStatusFromPrefs();
        final loggingIn = state.location == '/login' || state.location == '/signup' || state.location == '/forgot';

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
          path: '/forgot',
          builder: (context, state) => const SendOtpScreen(),
        ),
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),

        /// ✅ MOVE `/videoPlayer` OUTSIDE `ShellRoute`
        GoRoute(
          path: '/videoPlayer',
          pageBuilder: (context, state) {
            final videoUrl = state.queryParams['videoUrl'] ?? "https://www.youtube.com/watch?v=IWXpkfwimo0";
            final videoName = state.queryParams['videoName'] ?? "Default Video";

            return CustomTransitionPage(
              key: state.pageKey,
              fullscreenDialog: true, // ✅ Ensures fullscreen without AppBar/BottomNav
              child: YoutubeVideoPlayer(videoUrl: videoUrl, videoName: videoName),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            );
          },
        ),

        /// ✅ SHELL ROUTE (Other routes remain inside this)
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(
              isDarkMode: _isDarkMode,
              onThemeChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
              child: child,
            );
          },
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const Homepage()),
            GoRoute(path: '/timelist', builder: (context, state) => TimeList()),
            GoRoute(path: '/lessonlist', builder: (context, state) => const LessonListPage()),
            GoRoute(
              path: '/videos/:lessonId',
              builder: (context, state) {
                final lessonId = int.parse(state.params['lessonId']!);
                return VideoListPage(lessonId: lessonId);
              },
            ),
            GoRoute(path: '/progress', builder: (context, state) => const ProgressPage()),
            GoRoute(path: '/achievement', builder: (context, state) => const AchievementPage()),
            GoRoute(path: '/algorithm', builder: (context, state) => AlgorithmCategoriesPage()),
            GoRoute(
              path: '/algorithm/:category',
              builder: (context, state) {
                final category = state.params['category']!;
                return AlgorithmDetailPage(category: category);
              },
            ),
            GoRoute(path: '/rubik', builder: (context, state) => const RubikCubePage()),
          ],
        ),
      ],
    );


    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Twist and Solve',
      routerConfig: router,
      theme: ThemeData.from(
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          onPrimary: darkHighLightColor,
          surface: backgroundColor,
          onSurface: darkHighLightColor,
        ),
      ).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: darkHighLightColor),
          titleTextStyle: TextStyle(color: darkHighLightColor, fontSize: 18),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: primaryColor,
          selectedIconTheme: IconThemeData(
            color: darkHighLightColor
          ),
          unselectedIconTheme: IconThemeData(
            color: darkHighLightColor
          ),
          selectedItemColor: darkHighLightColor,
          unselectedItemColor: darkHighLightColor,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
          elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: highlightColor,
          )
      ),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.dark(
          primary: darkPrimaryColor,
          onPrimary: darkHighlightColor,
          surface: darkBackgroundColor,
          onSurface: darkDarkHighLightColor,
        ),
      ).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: darkPrimaryColor,
          iconTheme: IconThemeData(color: darkDarkHighLightColor),
          titleTextStyle: TextStyle(color: darkDarkHighLightColor, fontSize: 18),
        ),
        bottomNavigationBarTheme:BottomNavigationBarThemeData(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          backgroundColor: darkPrimaryColor,
          selectedIconTheme: IconThemeData(
              color: darkHighlightColor
          ),
          unselectedIconTheme: IconThemeData(
              color: darkDarkHighLightColor
          ),
          selectedItemColor: darkHighlightColor,
          unselectedItemColor: darkDarkHighLightColor,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: darkDarkHighLightColor),
          bodyLarge: TextStyle(color: darkDarkHighLightColor),
          bodyMedium: TextStyle(color: darkDarkHighLightColor),
        ),
        cardTheme: CardTheme(
          color: darkPrimaryColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkHighlightColor
          )
        )
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
  DateTime timeBackPressed = DateTime.now();

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
    return WillPopScope(
      onWillPop: ()async{
        final difference = DateTime.now().difference(timeBackPressed);
        bool isExitWarning = true;
        isExitWarning=difference >= const Duration(seconds: 2);

        timeBackPressed = DateTime.now();

        if(isExitWarning){
          const message = "Press back again to Exit!";
          Fluttertoast.showToast(msg: message,fontSize: 18);
          return false;
        }
        else{
          Fluttertoast.cancel();
          return true;
        }
      },
      child: Scaffold(
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
              final profilePicture = userInfo['profilePicture'] ?? 'https://res.cloudinary.com/dfsrzlxbv/image/upload/v1737723374/twist_and_solve/profile_pictures/ProfileAvtar_pl4qbr.webp';
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(userName),
                    accountEmail: Text(email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.transparent, // Optional: For a transparent background
                      child: ClipOval(
                        child: Image.network(
                          profilePicture,
                          fit: BoxFit.cover, // Ensures the image covers the circle
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      context.go('/home');
                      Scaffold.of(context).closeDrawer();
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
                      Scaffold.of(context).closeDrawer();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.show_chart),
                    title: const Text('Progress'),
                    onTap: () {
                      context.go('/progress');
                      Scaffold.of(context).closeDrawer();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Achievement'),
                    onTap: () {
                      context.go('/achievement');
                      Scaffold.of(context).closeDrawer();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.functions),
                    title: const Text('Algorithm'),
                    onTap: () {
                      context.go('/algorithm');
                      Scaffold.of(context).closeDrawer();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: _logout, // Call the logout method
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(CupertinoIcons.cube),
                    title: const Text('3d Model of Rubik\'s Cube'),
                    onTap: () {
                      context.go('/rubik');
                      Scaffold.of(context).closeDrawer();
                    }, // Call the logout method
                  ),
                ],
              );
            },
          ),
        ),
        body: widget.child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Ensures the background color applies correctly
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
                case 4:
                  context.go('/achievement');
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.timer),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Times',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_collection_rounded),
                label: 'Lessons',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events),
                label: 'Achievement',
              ),
            ],
          ),


      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouter.of(context).location;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/timelist')) return 1;
    if (location.startsWith('/lessonlist')) return 2;
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/achievement')) return 4;
    return 0; // Default to home if no match
  }
}
//TODO: Give All Achievements
//TODO: open authorization
//TODO: see password ,login header change
//TODO: setting panel change
//TODO: refresstoken implement properly
//TODO: _showConfetti
/*

#f7e6ca,#d4c5ae,#82796b,#594423


* */