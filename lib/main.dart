import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_tpm_prak/bottomNavBar.dart';
import 'package:project_tpm_prak/login.dart';
import 'package:project_tpm_prak/models/boxes.dart';
import 'package:project_tpm_prak/models/favorite.dart';
import 'package:project_tpm_prak/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  //hive
  await Hive.initFlutter();

  //user
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>(HiveBox.user);

  //favorite
  Hive.registerAdapter(FavoriteAdapter());
  await Hive.openBox<Favorite>(HiveBox.favorites);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueGrey,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        cardColor: Colors.white.withOpacity(0.08),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Colors.white,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return BottomNavbar();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
