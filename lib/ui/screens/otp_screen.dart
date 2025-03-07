import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen.dart';
import 'dart:async';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<TextEditingController> otpControllers =
  List.generate(4, (index) => TextEditingController());
  int countdown = 60; // Temps en secondes
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void verifyOtp() {
    // Simulation de validation OTP
    String otp = otpControllers.map((controller) => controller.text).join();
    if (otp.length == 4) {
      Get.off(() => const HomeScreen()); // Aller à la page d'accueil
    } else {
      Get.snackbar("Erreur", "Veuillez entrer un code OTP valide",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

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
              'Vérification OTP Par Mail',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Nous vous avons envoyé un code de vérification sur votre adresse e-mail. Veuillez le saisir ici.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Spacer(),
            // Section blanche contenant les champs OTP et les boutons
            Container(
              width: double.infinity,
              height: 400,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    'Vérification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6AAB64),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Champs OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                          (index) => SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          controller: otpControllers[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Colors.grey[300],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bouton "Vérifier"
                  InkWell(
                    onTap: verifyOtp,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6AAB64),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        'Vérifier',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Texte du compte à rebours
                  Text(
                    countdown > 0
                        ? "Si vous n'avez pas encore reçu le code de vérification, détendez-vous ! Nous vous l'enverrons dans $countdown secondes."
                        : "Vous pouvez renvoyer un nouveau code.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  // Bouton "Renvoyer"
                  InkWell(
                    onTap: countdown == 0
                        ? () {
                      setState(() {
                        countdown = 60;
                        startCountdown();
                      });
                    }
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Renvoyer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: countdown == 0 ? Colors.black : Colors.grey,
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
