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

  });

  factory Pharmacie.fromJson(Map<String, dynamic> json) {
    var produitsList = json['produits'] as List;
    List<Produit> produits = produitsList.map((i) => Produit.fromJson(i)).toList();

    return Pharmacie(
      emplacement: json['emplacement'],
      fermeture: json['fermeture'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      nom: json['nom'],
      ouverture: json['ouverture'],
      telephone1: json['telephone1'],
      telephone2: json['telephone2'],
      produits: produits,
    );
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
    };
  }
}
