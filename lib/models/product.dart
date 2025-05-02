class Product {
  final String nom;
  final bool surOrdonnance;
  final double prixUnitaire;
  final int quantite;

  Product({
    required this.nom,
    required this.surOrdonnance,
    required this.prixUnitaire,
    required this.quantite,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      nom: map['nom'] ?? '',
      surOrdonnance: map['sur_ordonnance'] ?? false,
      prixUnitaire: (map['prix_unitaire'] as num?)?.toDouble() ?? 0.0,
      quantite: (map['quantite'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'sur_ordonnance': surOrdonnance,
      'prix_unitaire': prixUnitaire,
      'quantite': quantite,
    };
  }
}
