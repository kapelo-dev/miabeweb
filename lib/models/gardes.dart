class Garde {
  final DateTime dateDebut;
  final DateTime dateFin;
  final bool estActive;
  final List<String> pharmacieIds;

  Garde({
    required this.dateDebut,
    required this.dateFin,
    required this.estActive,
    required this.pharmacieIds,
  });

  factory Garde.fromJson(Map<String, dynamic> json) {
    return Garde(
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: DateTime.parse(json['dateFin']),
      estActive: json['estActive'],
      pharmacieIds: json['pharmacieIds'],
    );
  }
}

