import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Get.find<AuthViewModel>();
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier le mot de passe',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6AAB64),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6AAB64),
              const Color(0xFF6AAB64).withOpacity(0.8),
              Colors.white,
            ],
            stops: const [0.0, 0.2, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modification du mot de passe',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _oldPasswordController,
                            obscureText: _obscureOldPassword,
                    decoration: InputDecoration(
                      labelText: 'Ancien mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6AAB64)),
                      suffixIcon: IconButton(
                        icon: Icon(
                                  _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                                    _obscureOldPassword = !_obscureOldPassword;
                          });
                        },
                      ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6AAB64)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre ancien mot de passe';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6AAB64)),
                      suffixIcon: IconButton(
                        icon: Icon(
                                  _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6AAB64)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nouveau mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le nouveau mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6AAB64)),
                      suffixIcon: IconButton(
                        icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6AAB64)),
                      ),
                    ),
                    validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez confirmer votre nouveau mot de passe';
                              }
                              if (value != _newPasswordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                          ),
                        ],
                      ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final userId = authViewModel.currentUser?.id;
                                  if (userId == null) {
                                    throw Exception('Utilisateur non connecté');
                                  }

                                  final success = await authService.updateUser(
                                    userId: userId,
                                    nom: authViewModel.currentUser?.nom ?? '',
                                    email: authViewModel.currentUser?.email ?? '',
                                    telephone: authViewModel.currentUser?.telephone ?? '',
                                    adresse: authViewModel.currentUser?.adresse ?? '',
                                    oldPassword: _oldPasswordController.text,
                                    password: _newPasswordController.text,
                                  );

                                  if (success) {
                                    Get.back();
                                    Get.snackbar(
                                      'Succès',
                                      'Mot de passe modifié avec succès',
                                      backgroundColor: Colors.green.withOpacity(0.1),
                                      colorText: Colors.green,
                                      duration: const Duration(seconds: 3),
                                      borderRadius: 12,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  } else {
                                    Get.snackbar(
                                      'Erreur',
                                      'Ancien mot de passe incorrect',
                                      backgroundColor: Colors.red.withOpacity(0.1),
                                      colorText: Colors.red,
                                      duration: const Duration(seconds: 3),
                                      borderRadius: 12,
                                      margin: const EdgeInsets.all(16),
                                    );
                                  }
                                } catch (e) {
                                  Get.snackbar(
                                    'Erreur',
                                    'Une erreur est survenue: $e',
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    colorText: Colors.red,
                                    duration: const Duration(seconds: 3),
                                    borderRadius: 12,
                                    margin: const EdgeInsets.all(16),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6AAB64),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Enregistrer le nouveau mot de passe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}