class Produit {
  final String id;
  final String description;
  final String nom;
  final double prixUnitaire;
  final int quantite;
  final int quantiteEnStock;
  final bool surOrdonnance;

  Produit({
    required this.id,
    required this.description,
    required this.nom,
    required this.prixUnitaire,
    required this.quantite,
    required this.quantiteEnStock,
    required this.surOrdonnance,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      nom: json['nom'] ?? '',
      prixUnitaire: (json['prix'] ?? 0.0).toDouble(),
      quantite: json['quantite'] ?? 1,
      quantiteEnStock: json['quantite_en_stock'] ?? 0,
      surOrdonnance: json['sur_ordonnance'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'nom': nom,
      'prix': prixUnitaire,
      'quantite': quantite,
      'quantite_en_stock': quantiteEnStock,
      'sur_ordonnance': surOrdonnance,
    };
  }
}
