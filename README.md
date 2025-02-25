# miabe_pharmacie : Guide de Collaboration

Bienvenue dans le projet Flutter ! Ce guide vous aidera à démarrer avec le projet, en vous expliquant comment configurer votre environnement, travailler avec l'architecture MVVM, utiliser Firestore et interagir avec l'API GraphQL.

## Table des Matières

1. [Introduction](#introduction)
2. [Prérequis](#prérequis)
3. [Configuration du Projet](#configuration-du-projet)
4. [Architecture MVVM](#architecture-mvvm)
5. [Base de Données Firestore](#base-de-données-firestore)
6. [API GraphQL](#api-graphql)
7. [Contribution](#contribution)
8. [Support](#support)

## Introduction

Ce projet Flutter utilise l'architecture MVVM pour structurer le code de manière organisée et maintenable. Nous utilisons Firestore comme base de données et une API GraphQL pour certaines tâches spécifiques.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les outils suivants :

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- Un éditeur de code (par exemple, Visual Studio Code)
- Un compte Firebase pour accéder à Firestore

## Configuration du Projet

1. **Forker le Projet :**
   - Forker ce dépôt sur votre compte GitHub.
   - Cloner votre fork localement :
     ```bash
     git clone https://github.com/VOTRE_UTILISATEUR/miabePharmacie.git
     ```

2. **Configurer Firebase :**
   - Créer un projet Firebase sur la [console Firebase](https://console.firebase.google.com/).
   - Ajouter une application Android/iOS et suivre les instructions pour télécharger le fichier `google-services.json` ou `GoogleService-Info.plist`.
   - Placer ce fichier dans le répertoire `android/app` ou `ios/Runner` respectivement.

3. **Installer les Dépendances :**
   - Exécuter `flutter pub get` pour installer les dépendances nécessaires.

## Architecture MVVM

Le projet suit l'architecture MVVM (Model-View-ViewModel) pour séparer les préoccupations et rendre le code plus testable et maintenable. Voici une brève description des composants :

- **Model :** Représente les données et la logique métier.
- **View :** Représente l'interface utilisateur.
- **ViewModel :** Gère l'état de l'interface utilisateur et interagit avec le modèle.

## Base de Données Firestore

Firestore est déjà configuré dans le projet. Vous pouvez interagir avec la base de données en utilisant les services définis dans le répertoire `lib/services`.

- **Ajouter des Données :** Utilisez les méthodes fournies pour ajouter des documents à Firestore.
- **Lire des Données :** Utilisez les méthodes de lecture pour récupérer des documents ou des collections.

## API GraphQL

L'API GraphQL sert de pont entre l'application et Firestore pour certaines tâches spécifiques. Vous pouvez trouver les requêtes GraphQL dans le répertoire `lib/graphql`.

- **Requêtes :** Utilisez les requêtes définies pour interagir avec l'API.
- **Mutations :** Utilisez les mutations pour modifier les données.

## Contribution

1. **Créer une Branche :**
   - Créer une nouvelle branche pour votre fonctionnalité ou correction de bug :
     ```bash
     git checkout -b nom-de-la-branche
     ```

2. **Développer :**
   - Implémentez votre fonctionnalité ou correction.
   - Assurez-vous de suivre les bonnes pratiques de codage et d'ajouter des tests si nécessaire.

3. **Commit :**
   - Faire des commits avec des messages clairs et concis.

4. **Pull Request :**
   - Pousser votre branche vers votre fork :
     ```bash
     git push origin nom-de-la-branche
     ```
   - Ouvrir une pull request vers le dépôt principal.

## Support

Si vous avez des questions ou rencontrez des problèmes, n'hésitez pas à ouvrir une issue ou à contacter l'équipe de développement.

---

Merci de contribuer à ce projet ! Votre aide est précieuse pour améliorer et faire évoluer cette application.

# MiabePharmacie API REST

API REST pour la gestion des pharmacies au Togo. Cette API permet de localiser les pharmacies, vérifier les gardes et la disponibilité des médicaments.

## 🌐 URL de Base de l'API

```
https://miabe-pharmacie-api.onrender.com
```


## 📋 Liste des Endpoints

### 1. Vérification de l'API

```
GET https://miabe-pharmacie-api.onrender.com/
```
Réponse
{
"message": "API MiabePharmacie REST est en ligne !",
"status": "healthy"
}

### 2. Liste des pharmacies proches

```
GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/proches
```
Paramètres
latitude: 6.149593 (obligatoire)
longitude: 1.210302 (obligatoire)
rayon: 3.0 (optionnel, en km)
limit: 10 (optionnel)

Exemple : GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/proches?latitude=6.149593&longitude=1.210302&rayon=3.0


### 3. Liste des Pharmacies de Garde

```
GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/garde
```
Exemple de réponse
[
{
"id": "JUSTINE",
"nom": "Pharmacie Justine",
"emplacement": "291, Bd des Armées - Tokoin Habitat",
"telephone1": "96800931",
"telephone2": "22210001",
"ouverture": "08h00",
"fermeture": "18h00"
}
]


### 4. Pharmacies de Garde Proches

```
GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/garde/proches
```
Paramètres
latitude: 6.149593 (obligatoire)
longitude: 1.210302 (obligatoire)
rayon: 3.0 (optionnel, en km)
limit: 10 (optionnel)

Exemple : GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/garde/proches?latitude=6.149593&longitude=1.210302&rayon=3.0


### 5. Recherche de Médicaments

```
GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/avec-produits

# Paramètres
- latitude: 6.149593                      (obligatoire)
- longitude: 1.210302                     (obligatoire)
- produits: PARACETAMOL,IBUPROFENE       (obligatoire)
- rayon: 3.0                             (optionnel)
- minProducts: 1                         (optionnel)
- limit: 10                              (optionnel)

# Exemple
GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/avec-produits?latitude=6.149593&longitude=1.210302&produits=PARACETAMOL,IBUPROFENE
```

### 6. Pharmacies de Garde avec Médicaments
```http
GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/garde/produits

# Paramètres (identiques à l'endpoint précédent)

# Exemple
GET https://miabe-pharmacie-api.onrender.com/api/pharmacies/garde/produits?latitude=6.149593&longitude=1.210302&produits=PARACETAMOL,IBUPROFENE
```

## 📝 Format des Réponses

Les réponses sont en JSON. Exemple d'une pharmacie :
```json
{
    "id": "JUSTINE",
    "nom": "Pharmacie Justine",
    "emplacement": "291, Bd des Armées - Tokoin Habitat",
    "latitude": 6.1471788,
    "longitude": 1.2876636,
    "distance": 0.396,
    "telephone1": "96800931",
    "telephone2": "22210001",
    "produitsDisponibles": [
        {
            "nom": "PARACETAMOL",
            "prix_unitaire": 500,
            "quantite_en_stock": 100
        }
    ],
    "produitsCount": 1,
    "pourcentageDisponibilite": 50
}
```

## ⚠️ Notes Importantes

1. Les coordonnées (latitude/longitude) doivent être au format décimal
2. Les noms des produits doivent être en MAJUSCULES
3. La distance est calculée en kilomètres
4. Le rayon de recherche par défaut est de 3 km
5. La limite par défaut est de 10 pharmacies

## 🔍 Exemple d'Utilisation (JavaScript)

```javascript
// Recherche des pharmacies de garde proches
const latitude = 6.149593;
const longitude = 1.210302;

fetch(`https://miabe-pharmacie-api.onrender.com/api/pharmacies/garde/proches?latitude=${latitude}&longitude=${longitude}`)
    .then(response => response.json())
    .then(data => console.log(data))
    .catch(error => console.error('Erreur:', error));
```

## 📱 Utilisation avec Géolocalisation

```javascript
// Exemple avec la géolocalisation du navigateur
navigator.geolocation.getCurrentPosition(position => {
    const { latitude, longitude } = position.coords;
    // Utilisez ces coordonnées dans vos appels API
});
```
## 📱 Exemple d'Utilisation avec Flutter

### Installation des dépendances
Ajoutez ces dépendances dans votre `pubspec.yaml` :
```yaml
dependencies:
  http: ^1.1.0
  geolocator: ^10.0.0
```

### Service API
```dart
// lib/services/pharmacie_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class PharmacieService {
  static const String baseUrl = 'https://miabe-pharmacie-api.onrender.com/api';

  // Récupérer les pharmacies proches
  Future<List<dynamic>> getPharmaciesProches(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pharmacies/proches?latitude=$latitude&longitude=$longitude')
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des pharmacies');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupérer les pharmacies de garde avec produits
  Future<List<dynamic>> getPharmaciesGardeAvecProduits(
    double latitude, 
    double longitude, 
    List<String> produits
  ) async {
    try {
      final String produitsStr = produits.join(',');
      final response = await http.get(
        Uri.parse(
          '$baseUrl/pharmacies/garde/produits?latitude=$latitude&longitude=$longitude&produits=$produitsStr'
        )
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des pharmacies');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
```

### Utilisation avec Géolocalisation
```dart
// lib/screens/pharmacies_screen.dart
import 'package:geolocator/geolocator.dart';

class PharmaciesScreen extends StatefulWidget {
  @override
  _PharmaciesScreenState createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final PharmacieService _service = PharmacieService();
  List<dynamic> pharmacies = [];
  bool isLoading = false;

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Obtenir la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      // Récupérer les pharmacies
      final result = await _service.getPharmaciesProches(
        position.latitude,
        position.longitude
      );

      setState(() {
        pharmacies = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pharmacies Proches')),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: pharmacies.length,
            itemBuilder: (context, index) {
              final pharmacie = pharmacies[index];
              return ListTile(
                title: Text(pharmacie['nom']),
                subtitle: Text(pharmacie['emplacement']),
                trailing: Text('${pharmacie['distance'].toStringAsFixed(2)} km'),
                onTap: () {
                  // Navigation vers les détails
                },
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
```

### Recherche de Médicaments
```dart
// Exemple de recherche de médicaments
void rechercherMedicaments() async {
  try {
    final position = await Geolocator.getCurrentPosition();
    final pharmacies = await _service.getPharmaciesGardeAvecProduits(
      position.latitude,
      position.longitude,
      ['PARACETAMOL', 'IBUPROFENE']
    );
    
    // Utiliser les résultats...
    print(pharmacies);
  } catch (e) {
    print('Erreur: $e');
  }
}
```

Ces exemples montrent comment :
1. Configurer le service API
2. Gérer la géolocalisation
3. Afficher une liste de pharmacies
4. Gérer les états de chargement
5. Traiter les erreurs

## 🚨 Codes d'Erreur

- 200 : Succès
- 404 : Route non trouvée
- 500 : Erreur interne du serveur

## 👨‍💻 Développé par

GoldenDev74

## 📄 Licence

MIT


