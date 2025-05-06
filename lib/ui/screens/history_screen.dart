import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product.dart';
import '../../models/order.dart' as app_models;
import '../widget/history_card.dart';
import '../../theme/app_theme.dart';
import '../../utils/commande_status_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<app_models.Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _hideOrder(String orderId) async {
    try {
      // Simuler un délai de suppression
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _orders = _orders.where((order) => order.id != orderId).toList();
      });

      // Mettre à jour les préférences locales
      final prefs = await SharedPreferences.getInstance();
      final hiddenOrders = prefs.getStringList('hidden_orders') ?? [];
      if (!hiddenOrders.contains(orderId)) {
        hiddenOrders.add(orderId);
        await prefs.setStringList('hidden_orders', hiddenOrders);
      }
    } catch (e) {
      print('Erreur lors de la suppression de la commande: $e');
      // En cas d'erreur, afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue lors de la suppression'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final hiddenOrders = prefs.getStringList('hidden_orders') ?? [];
      
      if (userId == null || userId.isEmpty) {
        throw Exception('Aucun utilisateur connecté');
      }

      final pharmaciesSnapshot = await _firestore.collection('pharmacies').get();
      final List<app_models.Order> allOrders = [];

      await Future.wait(pharmaciesSnapshot.docs.map((pharmacyDoc) async {
        try {
          final pharmacyData = pharmacyDoc.data();
          final pharmacyName = pharmacyData['nom'] ?? 'Inconnu';
          final pharmacyAddress = pharmacyData['emplacement'] ?? 'Adresse inconnue';

          final commandesSnapshot = await pharmacyDoc.reference
              .collection('commandes')
              .where('utilisateur', isEqualTo: userId)
              .get();

          for (var commandeDoc in commandesSnapshot.docs) {
            try {
              if (hiddenOrders.contains(commandeDoc.id)) continue; // Skip hidden orders

              final data = commandeDoc.data();
              final produitsList = List<Map<String, dynamic>>.from(data['produits'] ?? []);
              final List<Product> produits = [];
              double total = 0;

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
                isHidden: hiddenOrders.contains(commandeDoc.id),
              );

              if (!order.isHidden) {
              allOrders.add(order);
              }
            } catch (e) {
              print('Erreur lors du traitement de la commande ${commandeDoc.id}: $e');
            }
          }
        } catch (e) {
          print('Erreur lors du traitement de la pharmacie ${pharmacyDoc.id}: $e');
        }
      }));

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

  int _getOrderCountByStatus(String status) {
    return _orders.where((o) {
      final orderStatus = (o.statusCommande ?? 'En attente').toLowerCase();
      switch (status.toLowerCase()) {
        case 'en cours':
          return orderStatus.contains('en cours') || 
                 orderStatus.contains('en_cours') ||
                 orderStatus.contains('en attente') ||
                 orderStatus.contains('en_attente');
        case 'validée':
          return orderStatus.contains('valid') || // Couvre 'validé', 'validée', 'valide'
                 orderStatus.contains('confirm'); // Couvre 'confirmé', 'confirmée'
        case 'annulée':
          return orderStatus.contains('annul'); // Couvre 'annulé', 'annulée'
        case 'récupérée':
          return orderStatus.contains('recup') || // Couvre 'récupéré', 'récupérée'
                 orderStatus.contains('termin'); // Couvre 'terminé', 'terminée'
        case 'total':
          return true; // Compte toutes les commandes
        default:
          return false;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final enCoursCount = _getOrderCountByStatus('en cours');
    final valideesCount = _getOrderCountByStatus('validée');
    final totalCount = _orders.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Miabé Pharmacie',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Historique des commandes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(
                          Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur de chargement',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadOrders,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
              padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  enCoursCount.toString(),
                                  'En cours',
                                  Icons.hourglass_empty,
                                  AppTheme.warningColor,
                                ),
                                _buildDivider(),
                                _buildStatItem(
                                  valideesCount.toString(),
                                  'Validées',
                                  Icons.check_circle_outline,
                                  AppTheme.successColor,
                                ),
                                _buildDivider(),
                                _buildStatItem(
                                  totalCount.toString(),
                                  'Total',
                                  Icons.shopping_bag_outlined,
                                  const Color.fromARGB(255, 13, 151, 190),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_orders.isEmpty)
                      SliverFillRemaining(
                        child: Center(
          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune commande trouvée',
                                  style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => HistoryCard(
                            order: _orders[index],
                            onHideOrder: _hideOrder,
                          ),
                          childCount: _orders.length,
                        ),
                      ),
                    ],
                  ),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            ),
          ),
        ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
