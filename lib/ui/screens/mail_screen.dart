import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miabe_pharmacie/viewmodels/auth_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';

class MailScreen extends StatelessWidget {
  const MailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthViewModel authViewModel = Get.find();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fond.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
                child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                      const Text(
                        'MIAWOÉ ZON',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    const SizedBox(height: 10),
                      const Text(
                        'connectez-vous pour continuer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                          'Adresse email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6AAB64),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextFormField(
                        controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Entrez votre email",
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6AAB64)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Mot de passe',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6AAB64),
                        ),
                      ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Entrez votre mot de passe",
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6AAB64)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                          ),
                      ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                        onPressed: () => authViewModel.signInWithEmail(
                              emailController.text,
                              passwordController.text,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6AAB64),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                        ),
                            child: const Text(
                              'Connexion',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ),
                        const SizedBox(height: 20),
                        Center(
                          child: OutlinedButton(
                        onPressed: () => authViewModel.signInWithGoogle(),
                            style: AppTheme.googleButtonStyle,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 24,
                        ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Continuer avec Google',
                                  style: AppTheme.googleButtonTextStyle,
                                ),
                              ],
                            ),
                          ),
                      ),
                    ],
                    ),
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