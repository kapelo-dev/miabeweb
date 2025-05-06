import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miabe_pharmacie/viewmodels/auth_view_model.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:country_picker/country_picker.dart';
import 'register_screen.dart';

class ScreenOption extends StatefulWidget {
  final Function(String) onSelected;

  const ScreenOption({super.key, required this.onSelected});

  @override
  State<ScreenOption> createState() => _ScreenOptionState();
}

class _ScreenOptionState extends State<ScreenOption> {
  String selectedOption = 'email';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  Country selectedCountry = Country(
    phoneCode: '228',
    countryCode: 'TG',
    e164Sc: 0,
    geographic: true,
    level: 0,
    name: 'Togo',
    example: 'Togo',
    displayName: 'Togo',
    displayNameNoCountryCode: 'TG',
    e164Key: '',
  );

  void _handleLogin() async {
    final AuthViewModel authViewModel = Get.find<AuthViewModel>();
    
    String identifier = selectedOption == 'email' 
        ? emailController.text.trim()
        : '+${selectedCountry.phoneCode}${phoneController.text.trim()}';
    String password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      if (selectedOption == 'email') {
        await authViewModel.signInWithEmail(identifier, password);
      } else {
        await authViewModel.verifyPhoneNumber(identifier, password);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de la connexion: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

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
          child: SingleChildScrollView(
        child: Column(
          children: [
                Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      const SizedBox(height: 24),
                    const Text(
                      'MIAWOÉ ZON',
                      style: TextStyle(
                        color: Colors.white,
                          fontSize: 36,
                        fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                    ),
                  ],
                ),
              ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 300,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Row(
                      children: [
                            Expanded(
                              child: _buildOptionTab(
                                icon: Icons.email_outlined,
                                title: 'Email',
                                isSelected: selectedOption == 'email',
                                onTap: () => setState(() => selectedOption = 'email'),
                              ),
                            ),
                            Expanded(
                              child: _buildOptionTab(
                                icon: Icons.phone_android,
                                title: 'Téléphone',
                                isSelected: selectedOption == 'phone',
                                onTap: () => setState(() => selectedOption = 'phone'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (selectedOption == 'email')
                        _buildTextField(
                          controller: emailController,
                          hintText: 'Adresse email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        )
                      else
                        _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                        'Se connecter',
                        style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 24),
                      Center(
                        child: OutlinedButton(
                          onPressed: () async {
                            final AuthViewModel authViewModel = Get.find<AuthViewModel>();
                            try {
                              await authViewModel.signInWithGoogle();
                            } catch (e) {
                              Get.snackbar(
                                'Erreur',
                                'Échec de la connexion avec Google: ${e.toString()}',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            side: const BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/google_logo.png',
                                height: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continuer avec Google',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Get.to(() => const RegisterScreen()),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Pas encore de compte ? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Créer un compte',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTab({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
                        child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
                              Text(
              title,
                                style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                favorite: ['TG'],
                countryListTheme: CountryListThemeData(
                  flagSize: 25,
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                  bottomSheetHeight: 500,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  inputDecoration: InputDecoration(
                    labelText: 'Rechercher',
                    hintText: 'Commencer à taper pour rechercher',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                      ),
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
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${selectedCountry.phoneCode}',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                hintText: 'Numéro de téléphone',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF6AAB64)), // Ajout de l'icône de téléphone
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: passwordController,
        obscureText: !isPasswordVisible,
        decoration: InputDecoration(
          hintText: 'Mot de passe',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400], size: 22),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[400],
              size: 22,
            ),
            onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}