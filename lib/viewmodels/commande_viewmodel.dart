import 'package:get/get.dart';
import 'package:miabe_pharmacie/models/commandes.dart';
import 'package:miabe_pharmacie/repositories/commandes_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommandeViewModel extends GetxController {
  final CommandesRepository _repository = CommandesRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Commande> commandes = <Commande>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Liste des statuts autorisés
  final List<String> _statutsAutorises = ['en_cours', 'validée'];

  @override
  void onInit() {
    super.onInit();
    print('CommandeViewModel initialized');
    fetchCommandes();
  }

  Future<void> fetchCommandes() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        print('Aucun utilisateur connecté');
        return;
      }

      // Récupérer les commandes en utilisant le repository et l'ID de l'utilisateur
      final allCommandes = await _repository.getCommandesForUser(userId);

      // Filtrer les commandes pour ne garder que celles avec les statuts autorisés
      final filteredCommandes = allCommandes
          .where((commande) =>
              _statutsAutorises.contains(commande.statusCommande.toLowerCase()))
          .toList();

      // Mettre à jour la liste des commandes
      commandes.value = filteredCommandes;
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCommandeStatus(
      String pharmacieId, String commandeId, String newStatus) async {
    try {
      await _repository.updateCommandeStatus(
          pharmacieId, commandeId, newStatus);
      await fetchCommandes(); // Rafraîchir la liste après la mise à jour
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      Get.snackbar(
          'Erreur', 'Impossible de mettre à jour le statut de la commande');
    }
  }

  // Méthode pour rafraîchir la liste des commandes
  Future<void> refreshCommandes() async {
    return fetchCommandes();
  }
}
