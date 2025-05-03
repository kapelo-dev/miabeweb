import '../models/commande_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';

class CommandeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CommandeModel>> getCommandesForUser(String userId) async {
    try {
      List<CommandeModel> userCommandes = [];

      // Obtenir toutes les pharmacies
      final pharmaciesSnapshot = await _firestore
          .collection(FirebaseConstants.pharmaciesCollection)
          .get();

      // Pour chaque pharmacie, chercher les commandes de l'utilisateur
      for (var pharmacie in pharmaciesSnapshot.docs) {
        final commandesSnapshot = await pharmacie.reference
            .collection(FirebaseConstants.ordersCollection)
            .where(FirebaseConstants.userIdField, isEqualTo: userId)
            .get();

        for (var commandeDoc in commandesSnapshot.docs) {
          final commandeData = commandeDoc.data();
          
          // Convertir les items de la commande
          List<CommandeItem> items = [];
          num montantTotal = 0;
          
          for (var produit in (commandeData[FirebaseConstants.orderProductsField] as List)) {
            final produitRef = await pharmacie.reference
                .collection(FirebaseConstants.productsCollection)
                .doc(produit[FirebaseConstants.productNameField])
                .get();
                
            if (produitRef.exists) {
              final produitData = produitRef.data()!;
              final prixReel = produitData[FirebaseConstants.productPriceField] as num;
              final quantite = produit[FirebaseConstants.productQuantityField] as num;
              
              items.add(
                CommandeItem(
                  nom: produit[FirebaseConstants.productNameField],
                  description: produitData[FirebaseConstants.productDescriptionField] ?? '',
                  quantite: quantite.toInt(),
                  prix: prixReel.toDouble(),
                ),
              );
              
              montantTotal += prixReel * quantite;
            }
          }
          
          userCommandes.add(
            CommandeModel(
              code_commande: commandeData[FirebaseConstants.orderCodeField] ?? '',
              date: commandeData[FirebaseConstants.orderDateField].toString().split(' ')[0],
              pharmacieNom: pharmacie.get(FirebaseConstants.pharmacyNameField),
              pharmacieAdresse: pharmacie.get(FirebaseConstants.pharmacyAddressField) ?? '',
              items: items,
              total: '$montantTotal FCFA',
              heureRetrait: commandeData['heure_retrait'] ?? '',
              status: commandeData[FirebaseConstants.orderStatusField] ?? 'en attente',
            ),
          );
        }
      }
      
      return userCommandes;
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      throw Exception('Impossible de récupérer les commandes: $e');
    }
  }
}
