import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miabe_pharmacie/models/commandes.dart';

class CommandesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer toutes les commandes d'un utilisateur à travers toutes les pharmacies
  Future<List<Commande>> getCommandesForUser(String userName) async {
    try {
      // Récupérer toutes les pharmacies
      QuerySnapshot pharmaciesSnapshot =
          await _firestore.collection('pharmacies').get();

      // Créer une liste pour stocker toutes les futures requêtes
      List<Future<QuerySnapshot>> commandesFutures = [];

      // Pour chaque pharmacie, préparer une requête pour les commandes
      for (var pharmacie in pharmaciesSnapshot.docs) {
        commandesFutures.add(pharmacie.reference
            .collection('commandes')
            .where('utilisateur', isEqualTo: userName)
            .orderBy('date_commande', descending: true)
            .get());
      }

      // Exécuter toutes les requêtes en parallèle
      List<QuerySnapshot> commandesSnapshots =
          await Future.wait(commandesFutures);

      // Combiner tous les résultats
      List<Commande> allCommandes = [];
      for (var i = 0; i < commandesSnapshots.length; i++) {
        var pharmacieId = pharmaciesSnapshot.docs[i].id;
        for (var doc in commandesSnapshots[i].docs) {
          allCommandes.add(Commande.fromFirestore(doc, pharmacieId));
        }
      }

      // Trier toutes les commandes par date
      allCommandes.sort((a, b) => b.dateCommande.compareTo(a.dateCommande));

      return allCommandes;
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      return [];
    }
  }

  // Récupérer une commande spécifique
  Future<Commande?> getCommande(String pharmacieId, String commandeId) async {
    try {
      final doc = await _firestore
          .collection('pharmacies')
          .doc(pharmacieId)
          .collection('commandes')
          .doc(commandeId)
          .get();

      if (!doc.exists) return null;

      return Commande.fromFirestore(doc, pharmacieId);
    } catch (e) {
      print('Erreur lors de la récupération de la commande: $e');
      return null;
    }
  }

  // Mettre à jour le statut d'une commande
  Future<void> updateCommandeStatus(
      String pharmacieId, String commandeId, String newStatus) async {
    try {
      await _firestore
          .collection('pharmacies')
          .doc(pharmacieId)
          .collection('commandes')
          .doc(commandeId)
          .update({'status_commande': newStatus});
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      throw e;
    }
  }
}