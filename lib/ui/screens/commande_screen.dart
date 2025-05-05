import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:miabe_pharmacie/models/commandes.dart';
import 'package:miabe_pharmacie/viewmodels/commande_viewmodel.dart';
import 'package:miabe_pharmacie/ui/widget/commande_card.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';

class CommandeScreen extends StatelessWidget {
  final CommandeViewModel _viewModel = Get.put(CommandeViewModel());

  CommandeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(
              'Mes Commandes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _viewModel.refreshCommandes(),
          ),
        ],
      ),
      body: Obx(() {
        if (_viewModel.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        if (_viewModel.error.isNotEmpty) {
          return Center(
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
                  _viewModel.error.value,
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _viewModel.refreshCommandes,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aperçu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
            ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            _viewModel.commandes.where((c) => 
                              c.statusCommande.toLowerCase() == 'en_cours' || 
                              c.statusCommande.toLowerCase() == 'en attente'
                            ).length.toString(),
                            'En cours',
                            Icons.hourglass_empty,
                            AppTheme.warningColor,
                          ),
                          _buildDivider(),
                          _buildStatItem(
                            _viewModel.commandes.where((c) => 
                              c.statusCommande.toLowerCase() == 'validée' ||
                              c.statusCommande.toLowerCase() == 'validee' ||
                              c.statusCommande.toLowerCase() == 'validé' ||
                              c.statusCommande.toLowerCase() == 'valide'
                            ).length.toString(),
                            'Validées',
                            Icons.check_circle_outline,
                            AppTheme.successColor,
                          ),
                          _buildDivider(),
                          _buildStatItem(
                            _viewModel.commandes.length.toString(),
                            'Total',
                            Icons.shopping_bag_outlined,
                            const Color.fromARGB(255, 13, 151, 190),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_viewModel.commandes.isEmpty)
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
                  (context, index) {
              final commande = _viewModel.commandes[index];
                    return Hero(
                      tag: 'commande_${commande.id}',
                      child: CommandeCard(
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
                              backgroundColor: AppTheme.successColor,
                      colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Erreur',
                      'Impossible d\'annuler la commande',
                              backgroundColor: AppTheme.errorColor,
                      colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                    );
                  }
                },
                      ),
              );
            },
                  childCount: _viewModel.commandes.length,
                ),
          ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem(String count, String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
              children: [
                Container(
          padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
            color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
          child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
            ),
            const SizedBox(height: 4),
            Text(
          label,
                            style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.8),
                          ),
                        ),
                    ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[200],
    );
  }
}
