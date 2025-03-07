import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mail_screen.dart';
import 'phone_screen.dart';
import 'register_screen.dart';

class ScreenOption extends StatelessWidget {
  final Function(String) onSelected; // Ajout du paramètre onSelected

  const ScreenOption({super.key, required this.onSelected}); // Modifie le constructeur

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6AAB64),
      body: SafeArea(
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
              'connectez-vous pour continuer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const Spacer(),

            // Section blanche contenant les boutons
            Container(
              width: double.infinity,
              height: 400,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    'Se connecter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6AAB64),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Bouton "Continuez avec E-mail"
                  InkWell(
                    onTap: () => onSelected('email'), // Utilisation de onSelected pour informer MainScreen
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6AAB64),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Continuez avec E-mail',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Bouton "Continuez avec Numéro"
                  InkWell(
                    onTap: () => onSelected('phone'), // Utilisation de onSelected pour informer MainScreen
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6AAB64),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Continuez avec Numéro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bouton "Créer un compte"
                  InkWell(
                    onTap: () => Get.to(() => const RegisterScreen()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        'Créer Un compte',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
