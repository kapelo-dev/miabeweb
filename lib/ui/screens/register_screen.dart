import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miabe_pharmacie/viewmodels/auth_view_model.dart';
import 'package:country_picker/country_picker.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
    final AuthViewModel authViewModel = Get.find();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    RxString method = 'email'.obs;
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
                      'Créez votre compte',
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
                flex: 4,
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
                          'Nom et prénom',
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
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: "Entrez votre nom complet",
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
                              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6AAB64)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() => Row(
                          children: [
                            Radio(
                              value: 'email',
                              groupValue: method.value,
                              onChanged: (value) => method.value = value!,
                              activeColor: const Color(0xFF6AAB64),
                            ),
                            const Text('Email'),
                            const SizedBox(width: 20),
                            Radio(
                              value: 'phone',
                              groupValue: method.value,
                              onChanged: (value) => method.value = value!,
                              activeColor: const Color(0xFF6AAB64),
                            ),
                            const Text('Téléphone'),
                          ],
                        )),
                          const SizedBox(height: 20),
                        Obx(() => method.value == 'email'
                            ? Column(
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
                                ],
                              )
                            : Column(
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
                                      border: Border.all(color: const Color(0xFF6AAB64)),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            showCountryPicker(
                                              context: context,
                                              countryListTheme: CountryListThemeData(
                                                flagSize: 25,
                                                backgroundColor: Colors.white,
                                                textStyle: const TextStyle(fontSize: 16),
                                                bottomSheetHeight: 500,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                                inputDecoration: InputDecoration(
                                                  labelText: 'Rechercher',
                                                  prefixIcon: const Icon(Icons.search),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                ),
                                              ),
                                              onSelect: (Country country) {
                                                setState(() {
                                                  selectedCountry = country;
                                                });
                                              },
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Text(
                                                selectedCountry.flagEmoji,
                                                style: const TextStyle(fontSize: 25),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                "+${selectedCountry.phoneCode}",
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Icon(Icons.arrow_drop_down, color: Colors.black),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const VerticalDivider(
                                          color: Color(0xFF6AAB64),
                                          thickness: 1,
                                          indent: 8,
                                          endIndent: 8,
                                        ),
                                        Expanded(
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
                                      ],
                                    ),
                                  ),
                                ],
                              )),
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
                                hintText: "Créez votre mot de passe",
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
                              if (method.value == 'email') {
                                authViewModel.createUser(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  name: nameController.text,
                                );
                              } else {
                                final phone = "+${selectedCountry.phoneCode}${phoneController.text}";
                                authViewModel.createUser(
                                  phoneNumber: phone,
                                  password: passwordController.text,
                                  name: nameController.text,
                                );
                              }
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
                              'S\'inscrire',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OU',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: OutlinedButton(
                            onPressed: () => authViewModel.createUserWithGoogle(),
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
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () => Get.back(),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'J\'ai déjà un compte ? ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Se connecter',
                                    style: TextStyle(
                                      color: Color(0xFF6AAB64),
                                      fontWeight: FontWeight.w600,
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
              ),
            ],
            ),
        ),
      ),
    );
  }
}