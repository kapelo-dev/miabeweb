import '../models/commande_model.dart';

class CommandeService {
  Future<List<CommandeModel>> getCommandesForUser(String userId) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Remplacer par un vrai appel API
    return [
      CommandeModel(
        code_commande: 'CMD001',
        date: '2024-04-07',
        pharmacieNom: 'Pharmacie Centrale',
        pharmacieAdresse: '123 Rue du Commerce, Lomé',
        items: [
          CommandeItem(
            nom: 'Paracétamol',
            description: '500mg',
            quantite: 2,
            prix: 1500.0,
          ),
          CommandeItem(
            nom: 'Vitamine C',
            description: '1000mg, 30 comprimés',
            quantite: 1,
            prix: 3500.0,
          ),
        ],
        total: '6500 FCFA',
        heureRetrait: '15:30',
        status: 'en attente',
      ),
    ];
  }
}
