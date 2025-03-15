import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screen_option.dart';
import 'phone_screen.dart';
import 'mail_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _simulateProgress();
  }

  void _simulateProgress() async {
    const duration = Duration(seconds: 3);
    const totalSteps = 100;
    for (int i = 0; i <= totalSteps; i++) {
      await Future.delayed(duration ~/ totalSteps);
      setState(() {
        _progress = i / totalSteps;
      });
    }
    Get.off(() => ScreenOption(onSelected: (choice) {
      if (choice == 'email') {
        Get.to(() => const MailScreen());
      } else {
        Get.to(() => const PhoneScreen());
      }
    }));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6AAB64), // Couleur verte de la maquette
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/logo.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                'MIABÉ PHARMACIE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'APPLICATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 300,
                height: 20, // Augmentez la hauteur ici
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(25), right: Radius.circular(25),// Coins arrondis en haut
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
