import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../models/order.dart' as app_models;
import '../../models/product.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<app_models.Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null || userId.isEmpty) {
        throw Exception('Aucun utilisateur connecté');
      }

      // Récupérer toutes les pharmacies
      final pharmaciesSnapshot = await _firestore.collection('pharmacies').get();
      final List<app_models.Order> allOrders = [];

      // Pour chaque pharmacie, récupérer ses commandes
      await Future.wait(pharmaciesSnapshot.docs.map((pharmacyDoc) async {
        try {
          final pharmacyData = pharmacyDoc.data();
          final pharmacyName = pharmacyData['nom'] ?? 'Inconnu';
          final pharmacyAddress = pharmacyData['emplacement'] ?? 'Adresse inconnue';

          // Récupérer les commandes de l'utilisateur avec l'ID utilisateur
          final commandesSnapshot = await pharmacyDoc.reference
              .collection('commandes')
              .where('utilisateur', isEqualTo: userId)
              .get();

          // Traiter chaque commande
          for (var commandeDoc in commandesSnapshot.docs) {
            try {
              final data = commandeDoc.data();
              final produitsList = List<Map<String, dynamic>>.from(data['produits'] ?? []);
              final List<Product> produits = [];
              double total = 0;

              // Traiter les produits de la commande
              for (var produit in produitsList) {
                if (produit['nom'] == null) continue;

                final product = Product(
                  nom: produit['nom'].toString(),
                  prixUnitaire: (produit['prix_unitaire'] as num?)?.toDouble() ?? 0.0,
                  quantite: (produit['quantite'] as num?)?.toInt() ?? 1,
                  surOrdonnance: produit['sur_ordonnance'] ?? false,
                );

                produits.add(product);
                total += product.prixUnitaire * product.quantite;
              }

              // Créer l'objet Order
              final order = app_models.Order(
                id: data['id']?.toString() ?? commandeDoc.id,
                email: data['email']?.toString() ?? '',
                nom: data['nom']?.toString() ?? '',
                codeCommande: data['code_commande']?.toString() ?? commandeDoc.id,
                dateCommande: (data['date_commande'] as Timestamp?)?.toDate() ?? DateTime.now(),
                produits: produits,
                statusCommande: data['status_commande']?.toString() ?? 'En attente',
                pharmacie: pharmacyName,
                adresse: pharmacyAddress,
                total: total,
                utilisateur: userId,
              );

              allOrders.add(order);
            } catch (e) {
              print('Erreur lors du traitement de la commande ${commandeDoc.id}: $e');
            }
          }
        } catch (e) {
          print('Erreur lors du traitement de la pharmacie ${pharmacyDoc.id}: $e');
        }
      }));

      // Trier les commandes par date
      allOrders.sort((a, b) => b.dateCommande.compareTo(a.dateCommande));

      setState(() {
        _orders = allOrders;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Erreur lors du chargement des commandes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des commandes'),
        backgroundColor: const Color(0xFF6AAB64),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6AAB64),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFF6AAB64),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Exception: Impossible de récupérer les commandes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadOrders(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6AAB64),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.shopping_basket,
                              color: Color(0xFF6AAB64),
                              size: 72,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucune commande trouvée',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6AAB64),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error != null
                                  ? _error!
                                  : 'Vous n\'avez pas encore de commandes',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => Get.toNamed('/home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6AAB64),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Passer une commande'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _orders.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _buildOrderCard(order);
                        },
                      ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final normalizedStatus = status.toLowerCase().replaceAll('_', '').replaceAll('-', '');
    switch (normalizedStatus) {
      case 'encours':
        return Colors.orange;
      case 'validé':
      case 'validée':
      case 'récupérée':
      case 'récupéré':
        return Colors.green;
      case 'annulé':
      case 'annulée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return monthNames[month - 1];
  }

  String _getPickupTime(DateTime date) {
    final pickupTime = date.add(const Duration(hours: 1));
    return '${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(dynamic price) {
    try {
      if (price is int || price is double) {
        return price.toInt().toString();
      } else if (price is String) {
        return int.parse(price).toString();
      }
      return "0";
    } catch (e) {
      print('Erreur de formatage de prix: $e pour le prix: $price');
      return "0";
    }
  }

  Widget _buildOrderCard(app_models.Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de la commande et de la pharmacie
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Commande ${order.codeCommande}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.statusCommande)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.statusCommande,
                          style: TextStyle(
                            color: _getStatusColor(order.statusCommande),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.dateCommande),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_pharmacy_outlined, 
                        size: 16, 
                        color: Color(0xFF6AAB64)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.pharmacie,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (order.adresse.isNotEmpty)
                              Text(
                                order.adresse,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (order.statusCommande.toLowerCase() == 'récupérée' ||
                      order.statusCommande.toLowerCase() == 'validé')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Color(0xFF6AAB64)),
                          const SizedBox(width: 4),
                          Text(
                            'À retirer à ${_getPickupTime(order.dateCommande)}',
                            style: const TextStyle(
                              color: Color(0xFF6AAB64),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Liste des produits
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFECF4EC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produits',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6AAB64),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...order.produits
                      .map((produit) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        produit.nom.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${_formatPrice(produit.prixUnitaire)} FCFA × ${produit.quantite}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      if (produit.surOrdonnance)
                                        Row(
                                          children: const [
                                            Icon(
                                              Icons.medical_services_outlined,
                                              size: 14,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Sur ordonnance',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${_formatPrice(produit.prixUnitaire * produit.quantite)} FCFA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_formatPrice(order.total)} FCFA',
                        style: const TextStyle(
                          color: Color(0xFF6AAB64),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (order.statusCommande.toLowerCase() == 'récupérée' ||
                      order.statusCommande.toLowerCase() == 'validé')
                    TextButton(
                      onPressed: () {
                        _showOrderDetails(context, order);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerRight,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Voir plus',
                        style: TextStyle(
                          color: Color(0xFF6AAB64),
                          fontWeight: FontWeight.w500,
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

  void _showOrderDetails(BuildContext context, app_models.Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commande ${order.codeCommande}'),
            Text(
              _formatDate(order.dateCommande),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pharmacie
              const Text(
                'Pharmacie',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6AAB64),
                ),
              ),
              const SizedBox(height: 4),
              Text(order.pharmacie),
              if (order.adresse.isNotEmpty) Text(order.adresse),
              const SizedBox(height: 16),

              // Statut
              Row(
                children: [
                  const Text(
                    'Statut:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.statusCommande)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.statusCommande,
                      style: TextStyle(
                        color: _getStatusColor(order.statusCommande),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Liste des produits
              const Text(
                'Produits',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6AAB64),
                ),
              ),
              const SizedBox(height: 8),
              ...order.produits.map((produit) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                produit.nom.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (produit.surOrdonnance)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text(
                                  'Ordonnance',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${_formatPrice(produit.prixUnitaire)} FCFA × ${produit.quantite}'),
                            Text(
                              '${_formatPrice(produit.prixUnitaire * produit.quantite)} FCFA',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),

              // Total
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${_formatPrice(order.total)} FCFA',
                    style: const TextStyle(
                      color: Color(0xFF6AAB64),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Heure de retrait
              if (order.statusCommande.toLowerCase() == 'validé' ||
                  order.statusCommande.toLowerCase() == 'récupérée')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Color(0xFF6AAB64)),
                      const SizedBox(width: 4),
                      Text(
                        'À retirer à ${_getPickupTime(order.dateCommande)}',
                        style: const TextStyle(
                          color: Color(0xFF6AAB64),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
  }
}
