import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as app_models;
import '../constants/firebase_constants.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<app_models.Order>> getOrders(String userName) async {
    try {
      List<app_models.Order> allOrders = [];

      // Obtenir toutes les pharmacies
      final pharmaciesSnapshot = await _firestore
          .collection(FirebaseConstants.pharmaciesCollection)
          .get();

      // Pour chaque pharmacie, chercher les commandes de l'utilisateur
      for (var pharmacie in pharmaciesSnapshot.docs) {
        final commandesSnapshot = await pharmacie.reference
            .collection(FirebaseConstants.ordersCollection)
            .where(FirebaseConstants.orderUserField, isEqualTo: userName)
            .get();

        for (var commandeDoc in commandesSnapshot.docs) {
          final commandeData = commandeDoc.data();

          // Récupérer les produits de la commande et leurs prix réels
          List<Map<String, dynamic>> produitsAvecPrixReels = [];
          num montantTotal = 0;

          for (var produit
              in (commandeData[FirebaseConstants.orderProductsField] as List)) {
            final produitRef = await pharmacie.reference
                .collection(FirebaseConstants.productsCollection)
                .doc(produit[FirebaseConstants.productNameField])
                .get();

            if (produitRef.exists) {
              final produitData = produitRef.data()!;
              final prixReel =
                  produitData[FirebaseConstants.productPriceField] as num;
              final quantite =
                  produit[FirebaseConstants.productQuantityField] as num;

              produitsAvecPrixReels.add({
                ...produit,
                FirebaseConstants.productPriceField: prixReel,
              });

              montantTotal += prixReel * quantite;
            }
          }

          allOrders.add(
            app_models.Order.fromMap({
              ...commandeData,
              'id': commandeDoc.id,
              FirebaseConstants.pharmacyNameField:
                  pharmacie.get(FirebaseConstants.pharmacyNameField),
              FirebaseConstants.orderProductsField: produitsAvecPrixReels,
              FirebaseConstants.orderTotalField: montantTotal,
              FirebaseConstants.userEmailField:
                  commandeData[FirebaseConstants.userEmailField] ?? '',
              FirebaseConstants.userNameField:
                  commandeData[FirebaseConstants.userNameField] ?? '',
            }),
          );
        }
      }

      // Trier toutes les commandes par date
      allOrders.sort((a, b) => b.dateCommande.compareTo(a.dateCommande));

      return allOrders;
    } catch (e) {
      throw Exception('Impossible de récupérer les commandes: $e');
    }
  }

  // Autres méthodes du service...
}
