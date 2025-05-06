import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miabe_pharmacie/viewmodels/auth_view_model.dart';
import 'package:country_picker/country_picker.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
    final AuthViewModel authViewModel = Get.find();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
  Country selectedCountry = Country(
    phoneCode: "228",
    countryCode: "TG",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Togo",
    example: "90000000",
    displayName: "Togo",
    displayNameNoCountryCode: "TG",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
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
                          'Numéro de téléphone',
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
                        controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: "Entrez votre numéro de téléphone",
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                              prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF6AAB64)),
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
                            onPressed: () {
                              final phone = "+${selectedCountry.phoneCode}${phoneController.text}";
                              authViewModel.verifyPhoneNumber(phone, passwordController.text);
                            },
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