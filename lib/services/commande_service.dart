import '../models/commande_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase_constants.dart';
import '../models/commandes.dart';

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
        final pharmacieData = pharmacie.data();
        final pharmacieNom = pharmacieData[FirebaseConstants.pharmacyNameField] ?? 'Pharmacie';
        final pharmacieAdresse = pharmacieData[FirebaseConstants.pharmacyAddressField] ?? '';

        print('Données pharmacie: ${pharmacieData.toString()}'); // Debug
        print('Emplacement: $pharmacieAdresse'); // Debug

        final commandesSnapshot = await pharmacie.reference
            .collection(FirebaseConstants.ordersCollection)
            .where(FirebaseConstants.userIdField, isEqualTo: userId)
            .get();

        for (var doc in commandesSnapshot.docs) {
          final commande = Commande.fromFirestore(doc, pharmacie.id);
          final commandeModel = await commande.toCommandeModelAsync();
          userCommandes.add(commandeModel);
        }
      }

      return userCommandes;
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      return [];
    }
  }

  // Mettre à jour le statut d'une commande
  Future<void> updateCommandeStatus(String pharmacieId, String commandeId, String newStatus) async {
    try {
      print('Mise à jour de la commande: pharmacie=$pharmacieId, commande=$commandeId, status=$newStatus'); // Debug
      await _firestore
          .collection(FirebaseConstants.pharmaciesCollection)
          .doc(pharmacieId)
          .collection(FirebaseConstants.ordersCollection)
          .doc(commandeId)  // Utiliser l'ID du document, pas le code de commande
          .update({'status_commande': newStatus});
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      throw e;
    }
  }
}
