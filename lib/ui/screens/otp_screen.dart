import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miabe_pharmacie/viewmodels/auth_view_model.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
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

  @override
  void dispose() {
    _timer.cancel();
    otpController.dispose();
    super.dispose();
  }

  void verifyOtp() async {
    final AuthViewModel authViewModel = Get.find();
    String verificationId = Get.arguments;
    bool isSuccess = await authViewModel.verifyOTP(verificationId, otpController.text);

    if (isSuccess) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar(
        'Échec de la vérification',
        'Le code OTP est incorrect. Veuillez réessayer.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6AAB64),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset('lib/assets/images/logo.png', height: 120),
                    ),
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
                      'Vérification OTP',
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
                children: [
                      const Text(
                        'Code de vérification',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6AAB64),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          'Nous vous avons envoyé un code de vérification. Veuillez le saisir ci-dessous.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: PinCodeTextField(
                          appContext: context,
                          length: 4,
                          controller: otpController,
                          onChanged: (value) {},
                          onCompleted: (value) => verifyOtp(),
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(15),
                            fieldHeight: 60,
                            fieldWidth: 50,
                            activeFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            selectedFillColor: Colors.white,
                            activeColor: const Color(0xFF6AAB64),
                            inactiveColor: Colors.grey[300],
                            selectedColor: const Color(0xFF6AAB64),
                          ),
                          cursorColor: const Color(0xFF6AAB64),
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          keyboardType: TextInputType.number,
                          boxShadows: [
                            BoxShadow(
                              offset: const Offset(0, 1),
                              color: Colors.black12,
                              blurRadius: 10,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Temps restant: ${countdown}s',
                        style: TextStyle(
                          color: countdown > 10 ? Colors.grey : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6AAB64),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Vérifier',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (countdown == 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              countdown = 60;
                            });
                            startCountdown();
                            // Ici, vous pouvez ajouter la logique pour renvoyer le code
                          },
                          child: const Text(
                            'Renvoyer le code',
                        style: TextStyle(
                              color: Color(0xFF6AAB64),
                          fontSize: 16,
                              fontWeight: FontWeight.w600,
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
    );
  }
}