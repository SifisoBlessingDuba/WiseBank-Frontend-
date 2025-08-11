import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_screen.dart'; // Your login screen

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
      home: const SplashScreen(),
    );
  }
}
