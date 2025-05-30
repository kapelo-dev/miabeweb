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

  String _getDisplayName(dynamic user) {
    if (user?.nom?.isNotEmpty == true) {
      return user!.nom;
    } else if (user?.email?.isNotEmpty == true) {
      return user!.email;
    }
    return 'Utilisateur';
  }

  String _getInitial(dynamic user) {
    if (user?.nom?.isNotEmpty == true) {
      return user!.nom.substring(0, 1).toUpperCase();
    } else if (user?.email?.isNotEmpty == true) {
      return user!.email.substring(0, 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final authViewModel = Get.find<AuthViewModel>();
    final user = authViewModel.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF6AAB64),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF6AAB64),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6AAB64),
                      Color(0xFF6AAB64),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
      backgroundColor: Colors.white,
                      child: Text(
                        _getInitial(user),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6AAB64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getDisplayName(user),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  const Text(
                    'Paramètres du compte',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    icon: Icons.edit,
                    title: 'Modifier mon profil',
                    subtitle: 'Mettez à jour vos informations personnelles',
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
                  _buildOptionCard(
                    icon: Icons.history,
                    title: 'Historique',
                    subtitle: 'Consultez vos commandes passées',
            onTap: () {
              Navigator.push(
                context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
                  const SizedBox(height: 24),
                  const Text(
                    'Aide & Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    icon: Icons.help_outline,
                    title: 'Aide & Support',
                    subtitle: 'Obtenez de l\'aide pour utiliser l\'application',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
                  _buildOptionCard(
                    icon: Icons.contact_mail_outlined,
                    title: 'Nous contacter',
                    subtitle: 'Envoyez-nous vos questions ou suggestions',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                  title: const Text('Contactez-nous'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                              ListTile(
                                leading: Icon(Icons.email_outlined, color: Color(0xFF6AAB64)),
                                title: Text('Email'),
                                subtitle: Text('contact@miabe.com'),
                              ),
                              ListTile(
                                leading: Icon(Icons.phone_outlined, color: Color(0xFF6AAB64)),
                                title: Text('Téléphone'),
                                subtitle: Text('+228 92 36 74 25'),
                              ),
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
                  _buildOptionCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Politique de confidentialité',
                    subtitle: 'Consultez notre politique de confidentialité',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
                                Text('• Informations de profil (nom, email, téléphone)'),
                                Text('• Localisation pour trouver les pharmacies proches'),
                        Text('• Historique des commandes'),
                        SizedBox(height: 12),
                        Text(
                          'Utilisation des données :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                                Text('• Géolocalisation pour les pharmacies à proximité'),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red.shade400, size: 24),
                                const SizedBox(width: 8),
                                const Text('Déconnexion'),
                              ],
                            ),
                            content: const Text(
                              'Êtes-vous sûr de vouloir vous déconnecter ?',
                              style: TextStyle(fontSize: 16),
                            ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                        ),
                                child: const Text('Annuler'),
                      ),
                              ElevatedButton(
                        onPressed: () async {
                                  Navigator.pop(context);
                          try {
                                    await authViewModel.signOut();
                            Get.snackbar(
                              'Succès',
                              'Vous avez été déconnecté avec succès',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withOpacity(0.1),
                              colorText: Colors.green,
                              duration: const Duration(seconds: 3),
                                      borderRadius: 12,
                                      margin: const EdgeInsets.all(16),
                            );
                          } catch (e) {
                            Get.snackbar(
                              'Erreur',
                              'Erreur lors de la déconnexion: $e',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withOpacity(0.1),
                              colorText: Colors.red,
                                      duration: const Duration(seconds: 3),
                                      borderRadius: 12,
                                      margin: const EdgeInsets.all(16),
                            );
                          }
                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Déconnexion'),
                      ),
                    ],
                  ),
                );
              },
                      icon: Icon(Icons.logout, color: Colors.green.shade400),
                      label: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                ),
              ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6AAB64).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6AAB64),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
