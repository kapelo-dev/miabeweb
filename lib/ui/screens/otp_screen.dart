import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miabe_pharmacie/viewmodels/auth_view_model.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());
  int countdown = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        timer.cancel();
      }
    });
  }

 void verifyOtp() async {
  final AuthViewModel authViewModel = Get.find();
  String otp = otpControllers.map((controller) => controller.text).join();
  String verificationId = Get.arguments;

  // Ajoutez des logs pour vérifier les valeurs
  print('Verification ID: "$verificationId"');
  print('Entered OTP: "$otp"');

  // Appel de la méthode de vérification
  bool isSuccess = await authViewModel.verifyOTP(verificationId, otp);

  if (isSuccess) {
    // Navigation vers HomeScreen en cas de succès
    Get.offAllNamed('/home');
  } else {
    // Afficher un message d'erreur en cas d'échec
    Get.snackbar('Échec de la vérification', 'Le code OTP est incorrect. Veuillez réessayer.');
  }
}


  void _onOtpChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      } else {
        verifyOtp();
      }
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
            Image.asset('lib/assets/images/logo.png', height: 120),
            const SizedBox(height: 20),
            const Text('MIAWOÉ ZON',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Vérification OTP',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Entrez le code de vérification envoyé.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Spacer(),
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
                  const Text('Vérification',
                      style: TextStyle(
                          color: Color(0xFF6AAB64),
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          controller: otpControllers[index],
                          focusNode: focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          onChanged: (value) => _onOtpChanged(value, index),
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
                  InkWell(
                    onTap: verifyOtp,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6AAB64),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text('Vérifier',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    countdown > 0
                        ? "Renvoyer dans $countdown secondes."
                        : "Vous pouvez renvoyer un nouveau code.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
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
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
