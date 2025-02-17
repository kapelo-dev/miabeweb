class Pharmacie {
  late final String id;
  late final String nom;
  late final String emplacement;
  late final int telephone1;
  late final double latitude;
  late final double longitude;
  late final String ouverture;
  late final String fermeture;

  Pharmacie({
    required this.id,
    required this.nom,
    required this.emplacement,
    required this.telephone1,
    required this.longitude,
    required this.latitude,
    required this.ouverture,
    required this.fermeture,
  });

  factory Pharmacie.fromMap(Map<String, dynamic> map) {
    return Pharmacie(
      id: map['id'],
      nom: map['nom'],
      emplacement: map['emplacement'],
      telephone1: map['telephone1'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      ouverture: map['ouverture'],
      fermeture: map['fermeture'],
    );
  }
}
