import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/screen_option.dart';
import 'ui/screens/mail_screen.dart';
import 'ui/screens/phone_screen.dart';
import 'ui/screens/otp_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/register_screen.dart';
import 'services/auth_service.dart';
import 'viewmodels/auth_view_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialisation des dépendances
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);
  Get.put(AuthService(prefs));
  Get.put(AuthViewModel(Get.find<AuthService>()));

  final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Miabé Pharmacie',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => isAuthenticated ? const HomeScreen() : const SplashScreen()),
        GetPage(
          name: '/screen_option',
          page: () => ScreenOption(onSelected: (choice) {
            if (choice == 'email') Get.to(() => const MailScreen());
            else Get.to(() => const PhoneScreen());
          }),
        ),
        GetPage(name: '/otp', page: () => const OtpScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
      ],
      home: isAuthenticated ? const HomeScreen() : const SplashScreen(),
    );
  }
}
