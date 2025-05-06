import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miabe_pharmacie/models/commandes.dart';
import 'package:miabe_pharmacie/theme/app_theme.dart';
import 'package:miabe_pharmacie/ui/widget/commande_details_sheet.dart';
import 'package:miabe_pharmacie/utils/commande_status_utils.dart';

class CommandeCard extends StatelessWidget {
  final Commande commande;
  final Function(String) onCancelOrder;

  const CommandeCard({
    Key? key,
    required this.commande,
    required this.onCancelOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = CommandeStatusUtils.getStatusColor(commande.statusCommande);
    
    String _formatCodeCommande(String code) {
      if (code.length > 8) {
        return '${code.substring(0, 8)}...';
      }
      return code;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showCommandeDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
          children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CommandeStatusUtils.getStatusIcon(commande.statusCommande),
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                          _formatCodeCommande(commande.codeCommande),
                    style: const TextStyle(
                            fontSize: AppTheme.fontSizeNormal,
                      fontWeight: FontWeight.bold,
                            color: Colors.black,
              ),
            ),
            Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
              decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                            CommandeStatusUtils.formatStatus(commande.statusCommande),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: AppTheme.fontSizeXSmall,
                              fontWeight: FontWeight.w500,
                            ),
              ),
            ),
          ],
        ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy à HH:mm').format(commande.dateCommande),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.store_outlined,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          commande.pharmacieId,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeSmall,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                            Text(
                          '${commande.montantTotal} FCFA',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: AppTheme.fontSizeSmall,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  void _showCommandeDetails(BuildContext context) async {
    // Charger les détails de la commande de manière asynchrone
    final commandeModel = await commande.toCommandeModelAsync();
    
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => CommandeDetailsSheet(
          commande: commandeModel,
          onCancelOrder: (String _) async {
            // Afficher la boîte de dialogue de confirmation
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Confirmer l\'annulation'),
                content: const Text('Êtes-vous sûr de vouloir annuler cette commande ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Non'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Oui, annuler'),
                  ),
                ],
              ),
            );

            // Si l'utilisateur confirme
            if (confirm == true) {
              // Fermer la feuille de détails
              Navigator.of(context).pop();
              // Appeler la fonction d'annulation avec l'ID du document
              onCancelOrder(commande.id);
    }
          },
        ),
      ),
    );
  }
}
