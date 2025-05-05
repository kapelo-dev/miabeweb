import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderForm extends StatefulWidget {
  final Map<String, dynamic> selectedPharmacy;
  final Function(List<Map<String, dynamic>>) onOrderSubmit;

  const OrderForm({
    Key? key,
    required this.selectedPharmacy,
    required this.onOrderSubmit,
  }) : super(key: key);

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _selectedProducts = [];
  List<Map<String, dynamic>> _availableProducts = [];
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      // Récupérer la référence de la pharmacie
      final pharmacieRef = _firestore
          .collection('pharmacies')
          .doc(widget.selectedPharmacy['id']);

      // Récupérer les produits de la sous-collection
      final produitsSnapshot = await pharmacieRef
          .collection('produits')
          .get();

      if (produitsSnapshot.docs.isEmpty) {
        setState(() {
          _availableProducts = [];
          _isLoading = false;
        });
        return;
      }

      final produitsList = produitsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nom': doc.data()['nom'] ?? '',
          'description': doc.data()['description'] ?? '',
          'prix_unitaire': doc.data()['prix_unitaire'] ?? 0.0,
          'sur_ordonnance': doc.data()['sur_ordonnance'] ?? false,
        };
      }).toList();

      setState(() {
        _availableProducts = produitsList;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
      setState(() {
        _availableProducts = [];
        _isLoading = false;
      });
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits de cette pharmacie',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _availableProducts;
    return _availableProducts.where((product) {
      final name = product['nom'].toString().toLowerCase();
      final description = product['description']?.toString().toLowerCase() ?? '';
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  void _addProduct(Map<String, dynamic> product) {
    setState(() {
      final existingProduct = _selectedProducts.firstWhereOrNull(
        (p) => p['nom'] == product['nom'],
      );

      if (existingProduct != null) {
        existingProduct['quantite'] = (existingProduct['quantite'] ?? 1) + 1;
      } else {
        _selectedProducts.add({
          ...product,
          'quantite': 1,
        });
      }
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final product = _selectedProducts[index];
      final newQuantity = (product['quantite'] ?? 1) + delta;
      if (newQuantity > 0) {
        product['quantite'] = newQuantity;
      } else {
        _selectedProducts.removeAt(index);
      }
    });
  }

  double get _totalAmount {
    return _selectedProducts.fold(0, (sum, product) {
      final prix = product['prix_unitaire'] ?? product['prix'] ?? 0;
      return sum + (prix * (product['quantite'] ?? 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête avec le nom de la pharmacie
          Text(
            'Commander à ${widget.selectedPharmacy['nom']}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Liste des produits disponibles
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_availableProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aucun produit disponible dans cette pharmacie',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.2,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _getFilteredProducts().length,
                itemBuilder: (context, index) {
                  final product = _getFilteredProducts()[index];
                  final prix = product['prix_unitaire'] ?? product['prix'] ?? 0;
                  return ListTile(
                    title: Text(product['nom']),
                    subtitle: Text(product['description'] ?? ''),
                    trailing: Text('$prix FCFA'),
                    onTap: () => _addProduct(product),
                  );
                },
              ),
            ),

          if (_selectedProducts.isNotEmpty) ...[
            const Divider(height: 32),
            const Text(
              'Panier',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Liste des produits sélectionnés
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.2,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = _selectedProducts[index];
                  final prix = product['prix_unitaire'] ?? product['prix'] ?? 0;
                  return ListTile(
                    title: Text(product['nom']),
                    subtitle: Text('$prix FCFA'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _updateQuantity(index, -1),
                        ),
                        Text('${product['quantite'] ?? 1}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _updateQuantity(index, 1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Total: ${_totalAmount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 16),

            // Bouton de commande
            ElevatedButton(
              onPressed: () => widget.onOrderSubmit(_selectedProducts),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6AAB64),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Commander',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 