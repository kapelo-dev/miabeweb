import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import 'history_screen.dart';
import 'help_screen.dart';
import '../../constants/colors.dart';
import '../../viewmodels/edit_profile_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/auth_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final authViewModel = Get.find<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF6AAB64),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Color(0xFF6AAB64), size: 30),
            title: const Text('Modifier mon profil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => EditProfileViewModel(authService),
                    child: const EditProfileScreen(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.history, color: Color(0xFF6AAB64), size: 30),
            title: const Text('Historique'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Color(0xFF6AAB64), size: 30),
            title: const Text('Aide & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail,
                color: Color(0xFF6AAB64), size: 30),
            title: const Text('Nous contacter'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Contactez-nous'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: contact@miabe.com'),
                      SizedBox(height: 8),
                      Text('Téléphone: +228 92 36 74 25'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer',
                          style: TextStyle(color: Color(0xFF6AAB64))),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip,
                color: Color(0xFF6AAB64), size: 30),
            title: const Text('Politique de confidentialité'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Politique de confidentialité'),
                  content: const SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MIABÉ PHARMACIE s\'engage à protéger votre vie privée.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Données collectées :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            '• Informations de profil (nom, email, téléphone)'),
                        Text(
                            '• Localisation pour trouver les pharmacies proches'),
                        Text('• Historique des commandes'),
                        SizedBox(height: 12),
                        Text(
                          'Utilisation des données :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            '• Géolocalisation pour les pharmacies à proximité'),
                        Text('• Traitement des commandes et réservations'),
                        Text('• Communication via le chatbot'),
                        Text('• Envoi de notifications de suivi'),
                        SizedBox(height: 12),
                        Text(
                          'Sécurité :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('• Chiffrement des données personnelles'),
                        Text('• Protection des informations de commande'),
                        Text('• Codes de réservation sécurisés'),
                        SizedBox(height: 12),
                        Text(
                          'Vos droits :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('• Accès à vos données personnelles'),
                        Text('• Modification de vos informations'),
                        Text('• Suppression de votre compte'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer',
                          style: TextStyle(color: Color(0xFF6AAB64))),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Ferme la boîte de dialogue
                          try {
                            await authViewModel.signOut(); // Utilise le ViewModel pour la déconnexion qui gère déjà la navigation
                            // Affiche un message de confirmation
                            Get.snackbar(
                              'Succès',
                              'Vous avez été déconnecté avec succès',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withOpacity(0.1),
                              colorText: Colors.green,
                              duration: const Duration(seconds: 3),
                            );
                          } catch (e) {
                            // En cas d'erreur, affiche un message d'erreur
                            Get.snackbar(
                              'Erreur',
                              'Erreur lors de la déconnexion: $e',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withOpacity(0.1),
                              colorText: Colors.red,
                            );
                          }
                        },
                        child: const Text('Déconnexion',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 24),
                  SizedBox(width: 8),
                  Text('Déconnexion',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
