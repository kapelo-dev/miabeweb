import 'package:miabe_pharmacie/models/produits.dart';

class Pharmacie {
  final String emplacement;
  final String fermeture;
  final double latitude;
  final double longitude;
  final String nom;
  final String ouverture;
  final String telephone1;
  final String telephone2;
  final List<Produit> produits;
  final bool enGarde;

  Pharmacie({
    required this.emplacement,
    required this.fermeture,
    required this.latitude,
    required this.longitude,
    required this.nom,
    required this.ouverture,
    required this.telephone1,
    required this.telephone2, 
    required this.produits,
    this.enGarde = false,
  });

  factory Pharmacie.fromJson(Map<String, dynamic> json) {
    // Gérer le cas où produits est null
    List<Produit> produits = [];
    if (json['produits'] != null) {
      var produitsList = json['produits'] as List;
      produits = produitsList.map((i) => Produit.fromJson(i)).toList();
    }

    return Pharmacie(
      emplacement: _toStringValue(json['emplacement']),
      fermeture: _toStringValue(json['fermeture']),
      latitude: _toDoubleValue(json['latitude']),
      longitude: _toDoubleValue(json['longitude']),
      nom: _toStringValue(json['nom']),
      ouverture: _toStringValue(json['ouverture']),
      telephone1: _toStringValue(json['telephone1']),
      telephone2: _toStringValue(json['telephone2']),
      produits: produits,
      enGarde: json['enGarde'] is bool ? json['enGarde'] : (json['enGarde'] == 1),
    );
  }

  // Fonction utilitaire pour convertir n'importe quelle valeur en String
  static String _toStringValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  // Fonction utilitaire pour convertir n'importe quelle valeur en double
  static double _toDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'emplacement': emplacement,
      'fermeture': fermeture,
      'latitude': latitude,
      'longitude': longitude,
      'nom': nom,
      'ouverture': ouverture,
      'telephone1': telephone1,
      'telephone2': telephone2,
      'produits': produits.map((p) => p.toJson()).toList(),
      'enGarde': enGarde,
    };
  }
}
