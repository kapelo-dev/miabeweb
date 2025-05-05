import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/order.dart' as app_models;
import '../../theme/app_theme.dart';
import '../../utils/commande_status_utils.dart';

class HistoryCard extends StatelessWidget {
  final app_models.Order order;
  final Function(String) onHideOrder;

  const HistoryCard({
    Key? key,
    required this.order,
    required this.onHideOrder,
  }) : super(key: key);

  bool get _canHide {
    final status = (order.statusCommande ?? '').toLowerCase();
    return status == 'annulée' || status == 'annulee' || 
           status == 'récupérée' || status == 'recuperee';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = CommandeStatusUtils.getStatusColor(order.statusCommande ?? 'En attente');
    final statusIcon = CommandeStatusUtils.getStatusIcon(order.statusCommande ?? 'En attente');
    final statusLabel = CommandeStatusUtils.formatStatus(order.statusCommande ?? 'En attente');

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
        onTap: () => _showOrderDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande #${order.codeCommande}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.dateCommande),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_canHide)
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () => _confirmDelete(context),
                          tooltip: 'Supprimer la commande',
                          color: Colors.red[400],
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.local_pharmacy,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.pharmacie,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (order.adresse.isNotEmpty)
                          Text(
                            order.adresse,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.produits.length} produit${order.produits.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_formatPrice(order.total)} FCFA',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Détails de la commande',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailSection(
                'Informations générales',
                [
                  _buildDetailRow('Numéro', '#${order.codeCommande}'),
                  _buildDetailRow('Date', _formatDate(order.dateCommande)),
                  _buildDetailRow('Statut', CommandeStatusUtils.formatStatus(order.statusCommande ?? 'En attente')),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                'Pharmacie',
                [
                  _buildDetailRow('Nom', order.pharmacie),
                  if (order.adresse.isNotEmpty)
                    _buildDetailRow('Adresse', order.adresse),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                'Produits',
                order.produits.map((produit) => _buildDetailRow(
                  produit.nom,
                  '${_formatPrice(produit.prixUnitaire)} × ${produit.quantite}',
                )).toList(),
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                'Total',
                [
                  _buildDetailRow(
                    'Montant total',
                    '${_formatPrice(order.total)} FCFA',
                    isTotal: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Initialiser la localisation française
    initializeDateFormatting('fr_FR', null);
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui à ${DateFormat.Hm('fr_FR').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Hier à ${DateFormat.Hm('fr_FR').format(date)}';
    } else {
      return DateFormat.yMMMd('fr_FR').format(date);
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(price);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la commande'),
        content: const Text('Voulez-vous vraiment supprimer cette commande de l\'historique ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      onHideOrder(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La commande a été supprimée avec succès'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 