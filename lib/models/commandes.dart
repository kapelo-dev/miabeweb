import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miabe_pharmacie/models/produits.dart';
import 'package:miabe_pharmacie/models/commande_model.dart';

class Commande {
  final String id;
  final String codeCommande;
  final String pharmacieId;
  final String utilisateur;
  final DateTime dateCommande;
  final String statusCommande;
  final double montantTotal;
  final List<dynamic> produits;

  Commande({
    required this.id,
    required this.codeCommande,
    required this.pharmacieId,
    required this.utilisateur,
    required this.dateCommande,
    required this.statusCommande,
    required this.montantTotal,
    required this.produits,
  });

  // Méthode de conversion vers CommandeModel
  CommandeModel toCommandeModel() {
    List<CommandeItem> items = produits.map((produit) => CommandeItem(
      nom: produit['nom'] ?? '',
      description: produit['description'] ?? '',
      quantite: (produit['quantite'] as num?)?.toInt() ?? 0,
      prix: (produit['prix_unitaire'] as num?)?.toDouble() ?? 0.0,
    )).toList();

    // Conversion du statut
    String convertedStatus = statusCommande.toLowerCase();
    if (convertedStatus == 'en_cours') {
      convertedStatus = 'en attente';
    } else if (convertedStatus == 'validee' || convertedStatus == 'validée') {
      convertedStatus = 'confirmée';
    } else if (convertedStatus == 'annulee' || convertedStatus == 'annulée') {
      convertedStatus = 'annulée';
    } else if (convertedStatus == 'recuperee' || convertedStatus == 'récupérée') {
      convertedStatus = 'terminée';
    }

    return CommandeModel(
      code_commande: codeCommande,
      date: dateCommande.toIso8601String(),
      pharmacieNom: pharmacieId,
      pharmacieAdresse: '',  // L'adresse sera mise à jour par toCommandeModelAsync
      items: items,
      total: '$montantTotal FCFA',
      status: convertedStatus,
    );
  }

  // Nouvelle méthode asynchrone
  Future<CommandeModel> toCommandeModelAsync() async {
    try {
      final pharmacieDoc = await FirebaseFirestore.instance
          .collection('pharmacies')
          .doc(pharmacieId)
          .get();
          
      String pharmacieNom = pharmacieId;
      String pharmacieEmplacement = '';
      
      if (pharmacieDoc.exists) {
        final data = pharmacieDoc.data();
        if (data != null) {
          pharmacieNom = data['nom'] ?? pharmacieId;
          pharmacieEmplacement = data['emplacement'] ?? '';
        }
      }

      List<CommandeItem> items = produits.map((produit) => CommandeItem(
        nom: produit['nom'] ?? '',
        description: produit['description'] ?? '',
        quantite: (produit['quantite'] as num?)?.toInt() ?? 0,
        prix: (produit['prix_unitaire'] as num?)?.toDouble() ?? 0.0,
      )).toList();

      String convertedStatus = statusCommande.toLowerCase();
      if (convertedStatus == 'en_cours') {
        convertedStatus = 'en attente';
      } else if (convertedStatus == 'validee' || convertedStatus == 'validée') {
        convertedStatus = 'confirmée';
      } else if (convertedStatus == 'annulee' || convertedStatus == 'annulée') {
        convertedStatus = 'annulée';
      } else if (convertedStatus == 'recuperee' || convertedStatus == 'récupérée') {
        convertedStatus = 'terminée';
      }

      return CommandeModel(
        code_commande: codeCommande,
        date: dateCommande.toIso8601String(),
        pharmacieNom: pharmacieNom,
        pharmacieAdresse: pharmacieEmplacement,
        items: items,
        total: '$montantTotal FCFA',
        status: convertedStatus,
      );
    } catch (e) {
      print('Erreur lors de la récupération des infos de la pharmacie: $e');
      // En cas d'erreur, retourner le modèle de base
      return toCommandeModel();
    }
  }

  factory Commande.fromFirestore(DocumentSnapshot doc, String pharmacieId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Commande(
      id: doc.id,
      codeCommande: data['code_commande'] ?? '',
      pharmacieId: pharmacieId,
      utilisateur: data['utilisateur'] ?? '',
      dateCommande: (data['date_commande'] as Timestamp).toDate(),
      statusCommande: data['status_commande'] ?? 'en_attente',
      montantTotal: (data['montant_total'] ?? 0.0).toDouble(),
      produits: data['produits'] ?? [],
    );
  }

  factory Commande.fromJson(Map<String, dynamic> json) {
    List<ProduitCommande> produits = [];
    if (json['produits'] != null) {
      var produitsList = json['produits'] as List;
      produits = produitsList.map((i) => ProduitCommande.fromJson(i)).toList();
    }

    DateTime dateCommande;
    if (json['date_commande'] is Timestamp) {
      dateCommande = (json['date_commande'] as Timestamp).toDate();
    } else {
      dateCommande = DateTime.now();
    }

    return Commande(
      id: json['id'] ?? '',
      codeCommande: json['code_commande'] ?? '',
      pharmacieId: json['pharmacie_id'] ?? '',
      utilisateur: json['utilisateur'] ?? '',
      dateCommande: dateCommande,
      statusCommande: json['status_commande'] ?? 'En attente',
      montantTotal: json['montant_total'] ?? 0.0,
      produits: json['produits'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code_commande': codeCommande,
      'pharmacie_id': pharmacieId,
      'utilisateur': utilisateur,
      'date_commande': Timestamp.fromDate(dateCommande),
      'status_commande': statusCommande,
      'montant_total': montantTotal,
      'produits': produits.map((p) => p.toJson()).toList(),
    };
  }
}

class ProduitCommande {
  final String nom;
  final num prixUnitaire;
  final int quantite;
  final bool surOrdonnance;

  ProduitCommande({
    required this.nom,
    required this.prixUnitaire,
    required this.quantite,
    required this.surOrdonnance,
  });

  factory ProduitCommande.fromJson(Map<String, dynamic> json) {
    return ProduitCommande(
      nom: json['nom'] ?? '',
      prixUnitaire: json['prix_unitaire'] ?? 0,
      quantite: json['quantite'] ?? 1,
      surOrdonnance: json['sur_ordonnance'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prix_unitaire': prixUnitaire,
      'quantite': quantite,
      'sur_ordonnance': surOrdonnance,
    };
  }
}
