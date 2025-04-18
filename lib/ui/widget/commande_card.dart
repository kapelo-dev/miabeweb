import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miabe_pharmacie/models/commandes.dart';

class CommandeCard extends StatelessWidget {
  final Commande commande;
  final Function()? onTap;
  final Function(String)? onCancelOrder;

  const CommandeCard({
    Key? key,
    required this.commande,
    this.onTap,
    this.onCancelOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commande #${commande.codeCommande}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(commande.dateCommande),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${commande.montantTotal} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (commande.statusCommande.toLowerCase() == 'en_cours' &&
                        onCancelOrder != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          // Afficher une boîte de dialogue de confirmation
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmer l\'annulation'),
                                content: const Text(
                                    'Voulez-vous vraiment annuler cette commande ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Non'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onCancelOrder!(commande.id);
                                    },
                                    child: const Text('Oui'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Annuler'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Détails des produits:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...commande.produits.map((produit) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (produit as Map)['nom'] ?? 'Nom non disponible',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantité: ${produit['quantite']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Prix: ${produit['prix_unitaire']} FCFA',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        if (produit['sur_ordonnance'] == true)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Sur ordonnance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en_cours':
        return Colors.orange;
      case 'validée':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
