import 'package:flutter/material.dart';
import 'package:miabe_pharmacie/ui/widgets/order_form.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PharmacyDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> pharmacy;
  final Function(LatLng) onGetDirections;

  const PharmacyDetailsSheet({
    Key? key,
    required this.pharmacy,
    required this.onGetDirections,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // En-tête avec bouton de fermeture
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pharmacy['nom'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Contenu scrollable
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                children: [
                  // Informations de la pharmacie
                  _buildInfoSection(
                    icon: Icons.location_on,
                    title: 'Emplacement',
                    content: pharmacy['emplacement']?.toString() ?? '',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    icon: Icons.access_time,
                    title: 'Horaires',
                    content: '${pharmacy['ouverture']?.toString() ?? ''} - ${pharmacy['fermeture']?.toString() ?? ''}',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    icon: Icons.phone,
                    title: 'Téléphone',
                    content: pharmacy['telephone1']?.toString() ?? '',
                    isPhone: true,
                  ),
                  if (pharmacy['telephone2']?.toString().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    _buildInfoSection(
                      icon: Icons.phone,
                      title: 'Téléphone 2',
                      content: pharmacy['telephone2']?.toString() ?? '',
                      isPhone: true,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildInfoSection(
                    icon: Icons.directions,
                    title: 'Distance',
                    content: pharmacy['distance'] != null 
                        ? '${(pharmacy['distance'] as num).toStringAsFixed(2)} km'
                        : 'Distance non disponible',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onGetDirections(LatLng(
                            double.parse(pharmacy['latitude'].toString()),
                            double.parse(pharmacy['longitude'].toString()),
                          )),
                          icon: const Icon(Icons.directions),
                          label: const Text('Itinéraire'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Formulaire de commande
                  OrderForm(
                    selectedPharmacy: pharmacy,
                    onOrderSubmit: (products) async {
                      try {
                        final prefs = await Get.find<SharedPreferences>();
                        final userId = prefs.getString('userId');
                        
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez vous connecter pour passer une commande'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Afficher un indicateur de chargement
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        final commandeData = {
                          'produits': products.map((p) => {
                            'nom': p['nom'],
                            'quantite': p['quantite'],
                          }).toList(),
                          'status_commande': 'en_cours',
                          'utilisateur': userId,
                          'pharmacieId': pharmacy['id'] ?? pharmacy['_id'] ?? '',
                        };

                        print('Envoi de la commande: ${jsonEncode(commandeData)}');

                        final response = await http.post(
                          Uri.parse('https://miabe-pharmacie-api.onrender.com/api/pharmacies/commandes'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                          },
                          body: jsonEncode(commandeData),
                        );

                        // Fermer l'indicateur de chargement
                        Navigator.of(context).pop();

                        print('Réponse du serveur: ${response.statusCode}');
                        print('Corps de la réponse: ${response.body}');

                        if (response.statusCode == 200 || response.statusCode == 201) {
                          // Afficher le message de succès avant de fermer la modal
                          Get.snackbar(
                            'Succès',
                            'Votre commande a été envoyée avec succès !',
                            backgroundColor: Colors.green.withOpacity(0.8),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(10),
                            borderRadius: 10,
                          );

                          // Attendre un peu pour que l'utilisateur voie le message
                          await Future.delayed(const Duration(milliseconds: 500));

                          // Fermer la modal de détails de la pharmacie
                          Navigator.of(context).pop();

                          // Naviguer vers la page des commandes avec la bonne route
                          Get.toNamed('/home', arguments: 2);
                        } else {
                          final errorMessage = response.statusCode == 400 
                              ? 'Erreur dans les données de la commande'
                              : 'Erreur lors de l\'envoi de la commande';
                          
                          Get.snackbar(
                            'Erreur',
                            errorMessage,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(10),
                            borderRadius: 10,
                          );
                        }
                      } catch (e) {
                        // Fermer l'indicateur de chargement s'il est encore affiché
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }

                        print('Erreur lors de la commande: $e');
                        Get.snackbar(
                          'Erreur',
                          'Une erreur est survenue: $e',
                          backgroundColor: Colors.red.withOpacity(0.8),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 3),
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(10),
                          borderRadius: 10,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    bool isPhone = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              if (isPhone)
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse('tel:$content')),
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              else
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
} 