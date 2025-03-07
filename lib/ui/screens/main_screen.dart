import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'screen_option.dart';
import 'mail_screen.dart';
import 'phone_screen.dart';
import 'otp_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget? _currentScreen;

  @override
  void initState() {
    super.initState();
    _currentScreen = const SplashScreen();
    Future.delayed(const Duration(seconds: 3), _goToScreenOption); // Ajout d'un délai
  }

  void _goToScreenOption() {
    setState(() {
      _currentScreen = ScreenOption(onSelected: _goToAuthScreen); // Correction ici
    });
  }

  void _goToAuthScreen(String choice) {
    setState(() {
      _currentScreen = choice == 'email' ? const MailScreen() : const PhoneScreen();
    });
  }

  void _goToOtp() {
    setState(() {
      _currentScreen = const OtpScreen();
    });
  }

  void _goToHome() {
    setState(() {
      _currentScreen = const HomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentScreen ?? const Center(child: CircularProgressIndicator()),
    );
  }
}
