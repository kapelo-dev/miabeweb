import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchUrl(Uri uri) async {
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aide et Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6AAB64),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            'Comment localiser une pharmacie ?',
            [
              '1. Sur l\'écran d\'accueil, accédez à la carte interactive',
              '2. Visualisez toutes les pharmacies autour de vous',
              '3. Les pharmacies sont indiquées par des marqueurs sur la carte',
              '4. Cliquez sur un marqueur pour voir :',
              '   • Le nom de la pharmacie',
              '   • L\'adresse complète',
              '   • Les horaires d\'ouverture',
              '   • Le statut (ouverte/fermée)',
              '   • Les services disponibles'
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Comment utiliser le chatbot pour vérifier les stocks ?',
            [
              '1. Accédez à l\'assistant virtuel depuis le menu',
              '2. Posez votre question sur la disponibilité d\'un médicament',
              '3. Le chatbot vous informera en temps réel :',
              '   • Si le produit est disponible',
              '   • Dans quelles pharmacies',
              '   • Le prix',
              '   • Les alternatives disponibles si nécessaire'
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Comment réserver des médicaments ?',
            [
              '1. Trouvez votre produit via le chatbot ou la recherche',
              '2. Sélectionnez la pharmacie de votre choix',
              '3. Ajoutez les produits à votre panier',
              '4. Validez votre commande',
              '5. Un code unique de réservation vous sera envoyé',
              '6. Conservez ce code pour le retrait'
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Comment suivre mes commandes ?',
            [
              '1. Accédez à "Historique" depuis votre profil',
              '2. Visualisez toutes vos commandes',
              '3. Pour chaque commande, vous verrez :',
              '   • Le code de réservation',
              '   • La pharmacie concernée',
              '   • Le statut de la commande',
              '   • La date et l\'heure de retrait',
              '4. Recevez des notifications de suivi en temps réel'
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Comment gérer mon profil ?',
            [
              '1. Accédez à "Mon Profil" depuis le menu',
              '2. Vous pouvez modifier :',
              '   • Vos informations personnelles (nom, email)',
              '   • Votre numéro de téléphone',
              '   • Votre adresse',
              '3. Consultez votre historique de commandes',
              '4. Gérez vos préférences de notification'
            ],
          ),
          const SizedBox(height: 16),
          _buildContactSupport(context),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> content) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content
                  .map((text) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(text),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupport(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Besoin d\'aide supplémentaire ?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Contactez-nous'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email: support@miabe.com',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  _launchUrl(Uri(
                                    scheme: 'tel',
                                    path: '+22892367425',
                                  ));
                                },
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.phone,
                                      color: Color(0xFF6AAB64),
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      '+228 92 36 74 25',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  _launchUrl(
                                      Uri.parse('https://wa.me/+22892367425'));
                                },
                                child: Row(
                                  children: const [
                                    FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      '+228 92 36 74 25',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Fermer',
                                style: TextStyle(color: Color(0xFF6AAB64)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Contactez-nous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6AAB64),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
