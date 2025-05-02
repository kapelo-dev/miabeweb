import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

class MainScreen extends StatefulWidget {
  final bool isAuthenticated;

  const MainScreen({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (widget.isAuthenticated) {
        Get.offAll(() => const HomeScreen());
      } else {
        Get.offAll(() => const SplashScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}