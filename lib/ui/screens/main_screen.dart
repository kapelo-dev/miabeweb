import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

class MainScreen extends StatelessWidget {
  final bool isAuthenticated;

  const MainScreen({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return isAuthenticated ? const HomeScreen() : const SplashScreen();
  }
}