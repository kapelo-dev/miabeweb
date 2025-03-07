import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // Utiliser GetMaterialApp pour la navigation avec Get
      debugShowCheckedModeBanner: false,
      title: 'Miabé Pharmacie',
      theme: ThemeData(
        primaryColor: const Color(0xFF6AAB64),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainScreen(),
    );
  }
}
