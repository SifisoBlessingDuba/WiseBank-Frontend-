import 'package:flutter/material.dart';
import 'Pages/splash_screen.dart';
import 'Pages/login_page.dart';// Your login screen
import 'Pages/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Splash Demo',
      // home: const SplashScreen(),
      home: const LoginPage(),
    );
  }
}

