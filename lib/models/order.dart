import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class Order {
  final String id;
  final String email;
  final String nom;
  final List<Product> produits;
  final String codeCommande;
  final String pharmacie;
  final String adresse;
  final String statusCommande;
  final double total;
  final DateTime dateCommande;
  final String utilisateur;

  Order({
    required this.id,
    required this.email,
    required this.nom,
    required this.produits,
    required this.codeCommande,
    required this.pharmacie,
    required this.adresse,
    required this.statusCommande,
    required this.total,
    required this.dateCommande,
    required this.utilisateur,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    // Vérification et conversion sécurisée des champs
    final produitsList = map['produits'] as List?;
    final List<Product> produits = produitsList?.map((product) {
      if (product is Map<String, dynamic>) {
        return Product.fromMap(product);
      }
      throw FormatException('Format de produit invalide');
    }).toList() ?? [];

    // Conversion sécurisée de la date
    DateTime parsedDate;
    try {
      if (map['date_commande'] is Timestamp) {
        parsedDate = (map['date_commande'] as Timestamp).toDate();
      } else if (map['date_commande'] is DateTime) {
        parsedDate = map['date_commande'] as DateTime;
      } else {
        parsedDate = DateTime.now(); // Valeur par défaut
      }
    } catch (e) {
      parsedDate = DateTime.now(); // Valeur par défaut en cas d'erreur
    }

    // Conversion sécurisée du montant total
    double parsedTotal;
    try {
      if (map['montant_total'] is num) {
        parsedTotal = (map['montant_total'] as num).toDouble();
      } else if (map['montant_total'] is String) {
        parsedTotal = double.parse(map['montant_total']);
      } else {
        parsedTotal = 0.0; // Valeur par défaut
      }
    } catch (e) {
      parsedTotal = 0.0; // Valeur par défaut en cas d'erreur
    }

    return Order(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      nom: map['nom']?.toString() ?? '',
      produits: produits,
      codeCommande: map['code_commande']?.toString() ?? '',
      pharmacie: map['pharmacie']?.toString() ?? '',
      adresse: map['adresse']?.toString() ?? '',
      statusCommande: map['status_commande']?.toString() ?? 'En attente',
      total: parsedTotal,
      dateCommande: parsedDate,
      utilisateur: map['utilisateur']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'produits': produits.map((product) => product.toMap()).toList(),
      'code_commande': codeCommande,
      'pharmacie': pharmacie,
      'adresse': adresse,
      'status_commande': statusCommande,
      'montant_total': total,
      'date_commande': dateCommande,
      'utilisateur': utilisateur,
    };
  }
}
