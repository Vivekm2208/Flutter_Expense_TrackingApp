import 'package:flutter/material.dart';
import 'package:my_own_app/screens/start_screen.dart';
import 'package:my_own_app/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<bool> isSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSetupComplete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Roboto', primarySwatch: Colors.indigo),
      home: FutureBuilder<bool>(
        future: isSetupComplete(),
        builder: (context, snapshot) {
          // While waiting for SharedPreferences
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If setup is done → HomeScreen
          if (snapshot.data == true) {
            return const HomeScreen();
          }

          // Else → StartScreen
          return const StartScreen();
        },
      ),
    );
  }
}
