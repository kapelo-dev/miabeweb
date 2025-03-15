import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6AAB64),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Image.asset(
                      'lib/assets/images/logo.png',
                      height: 120,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'MIAWOÉ ZON',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'connectez vous pour continuer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Numéro de téléphone',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6AAB64)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6AAB64)),
                          ),
                          prefixText: '+228 ',
                          prefixStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Get.to(() => const OtpScreen()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6AAB64),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Continuer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10),
                            const Text(
                              'Continuez avec Google',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "vous n'avez pas de compte? Créer un compte",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
