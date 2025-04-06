class Produit {
  final String description;
  final String nom;
  final int prixUnitaire;
  final int quantiteEnStock;
  final bool surOrdonnance;

  Produit({
    required this.description,
    required this.nom,
    required this.prixUnitaire,
    required this.quantiteEnStock,
    required this.surOrdonnance,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      description: json['description'],
      nom: json['nom'],
      prixUnitaire: json['prix_unitaire'],
      quantiteEnStock: json['quantite_en_stock'],
      surOrdonnance: json['sur_ordonnance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'nom': nom,
      'prix_unitaire': prixUnitaire,
      'quantite_en_stock': quantiteEnStock,
      'sur_ordonnance': surOrdonnance,
    };
  }
}
