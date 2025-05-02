import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:miabe_pharmacie/models/commandes.dart';
import 'package:miabe_pharmacie/viewmodels/commande_viewmodel.dart';
import 'package:miabe_pharmacie/ui/widget/commande_card.dart';

class CommandeScreen extends StatelessWidget {
  final CommandeViewModel _viewModel = Get.put(CommandeViewModel());

  CommandeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _viewModel.refreshCommandes(),
          ),
        ],
      ),
      body: Obx(() {
        if (_viewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_viewModel.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _viewModel.error.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _viewModel.refreshCommandes,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (_viewModel.commandes.isEmpty) {
          return const Center(
            child: Text(
              'Aucune commande trouvée',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _viewModel.refreshCommandes,
          child: ListView.builder(
            itemCount: _viewModel.commandes.length,
            itemBuilder: (context, index) {
              final commande = _viewModel.commandes[index];
              return CommandeCard(
                commande: commande,
                onCancelOrder: (commandeId) async {
                  try {
                    await _viewModel.updateCommandeStatus(
                      commande.pharmacieId,
                      commandeId,
                      'annulée',
                    );
                    Get.snackbar(
                      'Succès',
                      'La commande a été annulée avec succès',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Erreur',
                      'Impossible d\'annuler la commande',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildCommandeCard(Commande commande) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${commande.codeCommande}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(commande.statusCommande),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    commande.statusCommande,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(commande.dateCommande)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${commande.montantTotal} FCFA',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Produits:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...commande.produits.map((produit) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '- ${produit.nom}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          '${produit.quantite} x ${produit.prixUnitaire} FCFA',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (produit.surOrdonnance)
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text(
                            'Sur ordonnance',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en attente':
        return Colors.orange;
      case 'en cours':
        return Colors.blue;
      case 'récupérée':
        return Colors.green;
      case 'annulée':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
