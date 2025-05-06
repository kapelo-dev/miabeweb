import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/screen_option.dart';
import 'ui/screens/mail_screen.dart';
import 'ui/screens/phone_screen.dart';
import 'ui/screens/otp_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/register_screen.dart';
import 'services/auth_service.dart';
import 'services/order_service.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/edit_profile_viewmodel.dart';
import 'viewmodels/history_viewmodel.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialisation des dépendances
  final prefs = await SharedPreferences.getInstance();
  final authService = AuthService(prefs);
  final orderService = OrderService();
  final historyViewModel = HistoryViewModel();

  Get.put(prefs);
  Get.put(authService);
  Get.put(AuthViewModel(authService));
  Get.put(EditProfileViewModel(authService));
  Get.put(historyViewModel);

  // Vérifier si l'utilisateur est déjà connecté
  final isAuthenticated = await authService.isUserLoggedIn();
  
  if (isAuthenticated) {
    // Récupérer l'ID de l'utilisateur
    final userId = await authService.getUserId();
    if (userId != null) {
      // Mettre à jour les données de l'utilisateur
      await historyViewModel.verifyUserInFirestore();
      
      // Configurer Firebase Auth si nécessaire
      if (userId.contains('@') && FirebaseAuth.instance.currentUser == null) {
        try {
          // Reconnecter l'utilisateur à Firebase Auth
          final email = prefs.getString(AuthService.KEY_USER_EMAIL);
          final hashedPassword = prefs.getString(AuthService.KEY_PASSWORD);
          if (email != null && hashedPassword != null) {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: hashedPassword,
            );
          }
        } catch (e) {
          print('Erreur de reconnexion Firebase: $e');
        }
      }
    }
  }

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Get.find<EditProfileViewModel>()),
        ChangeNotifierProvider(create: (_) => Get.find<HistoryViewModel>()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Miabé Pharmacie',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        getPages: [
          GetPage(
              name: '/',
              page: () =>
                  isAuthenticated ? const HomeScreen() : const SplashScreen()),
          GetPage(
            name: '/screen_option',
            page: () => ScreenOption(onSelected: (choice) {
              if (choice == 'email')
                Get.to(() => const MailScreen());
              else
                Get.to(() => const PhoneScreen());
            }),
          ),
          GetPage(name: '/otp', page: () => const OtpScreen()),
          GetPage(name: '/home', page: () => const HomeScreen()),
          GetPage(name: '/register', page: () => const RegisterScreen()),
        ],
        home: isAuthenticated ? const HomeScreen() : const SplashScreen(),
      ),
    );
  }
}
