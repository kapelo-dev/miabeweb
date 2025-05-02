class User {
  final String id;
  final String nom;
  final String email;
  final String telephone;
  final String adresse;
  final String password;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.adresse,
    required this.password,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      nom: map['nom_prenom'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      adresse: map['adresse'] ?? '',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_prenom': nom,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'password': password,
    };
  }
}
