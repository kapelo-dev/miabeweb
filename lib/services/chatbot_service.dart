import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pharmacies.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class ChatbotService {
  // Clé API Deepseek directement intégrée dans le code
  final String _apiKey = 'sk-fb9e9140957a4bc9aeb00179756e0a7a';
  final String _apiEndpoint = 'https://api.deepseek.com/v1/chat/completions';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Constructeur sans paramètre
  ChatbotService();

  // Récupérer les données des pharmacies depuis Firestore
  Future<List<Pharmacie>> getPharmacies() async {
    try {
      final snapshot = await _firestore.collection('pharmacies').get();
      if (snapshot.docs.isEmpty) {
        print('Aucune pharmacie trouvée dans Firestore');
        return _getMockPharmacies();
      }
      return snapshot.docs
          .map((doc) => Pharmacie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des pharmacies: $e');
      return _getMockPharmacies(); // Retourner des données fictives en cas d'erreur
    }
  }

  // Données fictives pour les tests quand Firebase échoue
  List<Pharmacie> _getMockPharmacies() {
    return [
      Pharmacie(
        nom: 'Pharmacie du Port',
        emplacement: 'Lomé, près du Grand Marché',
        latitude: 6.1319,
        longitude: 1.2238,
        ouverture: '7h30',
        fermeture: '20h',
        telephone1: '+228 22 21 45 67',
        telephone2: '',
        produits: [],
        enGarde: true,
      ),
      Pharmacie(
        nom: 'Pharmacie Saint Michel',
        emplacement: 'Agoe, Rue des Hôpitaux',
        latitude: 6.1743,
        longitude: 1.2174,
        ouverture: '8h',
        fermeture: '19h',
        telephone1: '+228 90 12 34 56',
        telephone2: '',
        produits: [],
        enGarde: false,
      ),
      Pharmacie(
        nom: 'Pharmacie Centrale de Lomé',
        emplacement: 'Avenue de la Libération, Lomé',
        latitude: 6.1277,
        longitude: 1.2125,
        ouverture: '24h',
        fermeture: '24h',
        telephone1: '+228 22 21 30 40',
        telephone2: '',
        produits: [],
        enGarde: true,
      )
    ];
  }

  // Récupérer les pharmacies de garde depuis Firestore
  Future<List<Pharmacie>> getPharmaciesGarde() async {
    try {
      final snapshot = await _firestore
          .collection('pharmacies')
          .where('enGarde', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isEmpty) {
        // Retourner les pharmacies de garde des données fictives
        return _getMockPharmacies().where((p) => p.enGarde).toList();
      }
      
      return snapshot.docs
          .map((doc) => Pharmacie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des pharmacies de garde: $e');
      return _getMockPharmacies().where((p) => p.enGarde).toList();
    }
  }

  // Récupérer les pharmacies qui ont certains produits
  Future<List<Pharmacie>> getPharmaciesAvecProduits(List<String> produits) async {
    try {
      final snapshot = await _firestore.collection('pharmacies').get();
      
      if (snapshot.docs.isEmpty) {
        return _getMockPharmacies();
      }
      
      final allPharmacies = snapshot.docs
          .map((doc) => Pharmacie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      return allPharmacies.where((pharmacie) {
        if (pharmacie.produits.isEmpty) return false;
        return pharmacie.produits.any((produit) => 
          produits.any((p) => produit.nom.toLowerCase().contains(p.toLowerCase())));
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des pharmacies avec produits: $e');
      return _getMockPharmacies();
    }
  }

  // Récupérer les pharmacies de garde avec certains produits
  Future<List<Pharmacie>> getPharmaciesGardeProduits(List<String> produits) async {
    try {
      final snapshot = await _firestore
          .collection('pharmacies')
          .where('enGarde', isEqualTo: true)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return _getMockPharmacies().where((p) => p.enGarde).toList();
      }
      
      final gardePharmacies = snapshot.docs
          .map((doc) => Pharmacie.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
          
      return gardePharmacies.where((pharmacie) {
        if (pharmacie.produits.isEmpty) return false;
        return pharmacie.produits.any((produit) => 
          produits.any((p) => produit.nom.toLowerCase().contains(p.toLowerCase())));
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des pharmacies de garde avec produits: $e');
      return _getMockPharmacies().where((p) => p.enGarde).toList();
    }
  }

  // Récupérer la position actuelle de l'utilisateur avec précision élevée
  Future<Position?> _getUserLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Vérifier si les services de localisation sont activés
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await _getLastKnownPosition();
      }

      // Vérifier les permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return await _getLastKnownPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return await _getLastKnownPosition();
      }

      // Tenter d'obtenir la position actuelle avec un timeout court
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium, // Réduire la précision pour accélérer
          timeLimit: Duration(seconds: 3), // Réduire le timeout
        );
        
        return position;
      } catch (timeoutError) {
        return await _getLastKnownPosition();
      }
    } catch (e) {
      return await _getLastKnownPosition();
    }
  }

  // Utiliser la dernière position connue comme fallback
  Future<Position?> _getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  // Calculer la distance entre deux points géographiques (en kilomètres) avec la formule de Haversine
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    if (lat1 == 0 && lon1 == 0) return double.infinity;
    if (lat2 == 0 && lon2 == 0) return double.infinity;
    
    // Rayon moyen de la Terre en kilomètres (valeur WGS-84)
    const double earthRadius = 6371.0088;
    
    // Conversion en radians
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    // Calcul de Haversine
    final double a = math.pow(math.sin(dLat / 2), 2) +
                     math.cos(_toRadians(lat1)) * 
                     math.cos(_toRadians(lat2)) * 
                     math.pow(math.sin(dLon / 2), 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;
    
    return distance;
  }

  // Convertir degrés en radians
  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  // Calculer la distance directement
  double calculateDistanceSynchronously(double startLatitude, double startLongitude, 
                                       double endLatitude, double endLongitude) {
    return _calculateDistance(startLatitude, startLongitude, endLatitude, endLongitude);
  }

  // Trier les pharmacies par distance - version SYNCHRONE pour éviter les problèmes
  List<Pharmacie> _sortPharmaciesByDistanceSync(List<Pharmacie> pharmacies, Position userPosition) {
    try {
      print('Tri synchrone des pharmacies par distance');
      print('Position utilisateur: ${userPosition.latitude}, ${userPosition.longitude}');
      
      // Liste pour stocker les pharmacies avec leurs distances
      final List<Map<String, dynamic>> pharmaciesWithDistance = [];
      
      // Calculer la distance pour chaque pharmacie
      for (var pharmacie in pharmacies) {
        try {
          if (pharmacie.latitude <= 0 || pharmacie.longitude <= 0) {
            print('Coordonnées invalides pour ${pharmacie.nom}: ${pharmacie.latitude}, ${pharmacie.longitude}');
            continue;
          }
          
          double distance = calculateDistanceSynchronously(
            userPosition.latitude, 
            userPosition.longitude,
            pharmacie.latitude,
            pharmacie.longitude
          );
          
          pharmaciesWithDistance.add({
            'pharmacie': pharmacie,
            'distance': distance
          });
          
          print('Distance à ${pharmacie.nom}: $distance km (coords: ${pharmacie.latitude}, ${pharmacie.longitude})');
        } catch (e) {
          print('Erreur lors du calcul de distance pour ${pharmacie.nom}: $e');
        }
      }
      
      // Trier par distance
      pharmaciesWithDistance.sort((a, b) => 
        (a['distance'] as double).compareTo(b['distance'] as double));
      
      // Extraire uniquement les pharmacies triées
      final sortedPharmacies = pharmaciesWithDistance
          .map((item) => item['pharmacie'] as Pharmacie)
          .toList();
      
      if (sortedPharmacies.isNotEmpty) {
        print('Pharmacie la plus proche: ${sortedPharmacies[0].nom}');
      }
      
      return sortedPharmacies;
    } catch (e) {
      print('Erreur lors du tri par distance: $e');
      return pharmacies;
    }
  }

  // Envoyer une requête à l'API Deepseek
  Future<String> sendMessageToDeepseek(String userMessage, String contextData) async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': '''Tu es un assistant virtuel spécialisé dans les informations sur les pharmacies au Togo.
              Voici des données sur les pharmacies que tu peux utiliser pour répondre aux questions: $contextData
              Réponds de manière précise et concise, en donnant les informations pertinentes comme 
              le nom de la pharmacie, l'adresse, les horaires d'ouverture et les numéros de téléphone.
              Utilise TOUJOURS des caractères simples (sans accents ni caractères spéciaux).'''
            },
            {
              'role': 'user',
              'content': userMessage
            }
          ],
          'temperature': 0.5, // Réduire la température pour des réponses plus directes
          'max_tokens': 300, // Réduire pour des réponses plus concises
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Désolé, je n\'ai pas pu générer une réponse.';
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      return 'Désolé, je n\'ai pas pu traiter votre demande. Veuillez réessayer.';
    }
  }

  // Préparer les données de contexte pour l'IA de manière optimisée
  Future<String> prepareContextData(String userMessage) async {
    try {
      // Création d'un objet pour stocker le contexte et les pharmacies
      String contextData = '';
      List<Pharmacie> pharmacies = [];
      
      // Analyse rapide du message pour déterminer quelles données récupérer
      bool mentionsProduit = userMessage.toLowerCase().contains('medicament') || 
                           userMessage.toLowerCase().contains('produit');
      bool mentionsGarde = userMessage.toLowerCase().contains('garde');
      bool mentionsZone = _detecterZone(userMessage) != null;

      // Exécution parallèle de la récupération des pharmacies et de la position utilisateur
      final futurePharmas = _getFarmacies(mentionsProduit, mentionsGarde, userMessage);
      final futurePosition = _getUserLocation();
      
      // Attendre les résultats
      pharmacies = await futurePharmas;
      final userPosition = await futurePosition;

      // Si aucune pharmacie n'est trouvée
      if (pharmacies.isEmpty) {
        pharmacies = _getMockPharmacies();
        contextData += "(donnees fictives) ";
      }

      // Construire le début du contexte
      if (mentionsGarde && mentionsProduit) {
        contextData += 'Pharmacies de garde avec les produits demandes: ';
      } else if (mentionsGarde) {
        contextData += 'Pharmacies de garde: ';
      } else if (mentionsProduit) {
        contextData += 'Pharmacies avec les produits demandes: ';
      } else {
        contextData += 'Liste des pharmacies: ';
      }

      // Filtrer par zone ou trier par distance
      if (mentionsZone) {
        String? zone = _detecterZone(userMessage);
        if (zone != null) {
          pharmacies = pharmacies.where((p) => 
            p.emplacement.toLowerCase().contains(zone.toLowerCase())).toList();
          contextData += '(dans la zone $zone) ';
        }
      } else if (userPosition != null) {
        // Tri synchrone direct avec la position déjà récupérée
        pharmacies = _sortPharmaciesByDistanceSync(pharmacies, userPosition);
        contextData += '(triees par proximite) ';
      }

      // Limiter à 5 pharmacies maximum pour réduire la taille des données
      pharmacies = pharmacies.length > 5 ? pharmacies.sublist(0, 5) : pharmacies;

      // Construire la chaîne de données de contexte de manière compacte
      for (var i = 0; i < pharmacies.length; i++) {
        final p = pharmacies[i];
        contextData += '\n${i+1}. ${p.nom} - ${p.emplacement}, ' +
                      '${p.ouverture}-${p.fermeture}, Tel: ${p.telephone1}';
        
        if (userPosition != null && p.latitude > 0 && p.longitude > 0) {
          double distance = calculateDistanceSynchronously(
            userPosition.latitude, userPosition.longitude,
            p.latitude, p.longitude
          );
          contextData += ' (${distance.toStringAsFixed(1)} km)';
        }
        
        // Ajouter les produits de manière concise uniquement si demandé
        if (mentionsProduit && p.produits.isNotEmpty) {
          List<String> medicaments = _extractMedicaments(userMessage);
          if (medicaments.isNotEmpty) {
            List<String> produitsDisponibles = p.produits
                .where((produit) => medicaments.any((m) => 
                  produit.nom.toLowerCase().contains(m.toLowerCase())))
                .map((p) => '${p.nom}: ${p.prixUnitaire}F')
                .toList();
            
            if (produitsDisponibles.isNotEmpty) {
              contextData += ', Produits: ${produitsDisponibles.join(', ')}';
            }
          }
        }
      }

      return contextData;
    } catch (e) {
      return 'Pharmacies à Lomé: Pharmacie du Port (centre), Pharmacie Saint Michel (Agoe), Pharmacie Centrale (24h/24).';
    }
  }
  
  // Méthode pour récupérer les pharmacies selon les critères (pour exécution parallèle)
  Future<List<Pharmacie>> _getFarmacies(bool mentionsProduit, bool mentionsGarde, String userMessage) async {
    try {
      if (mentionsGarde && mentionsProduit) {
        List<String> medicaments = _extractMedicaments(userMessage);
        if (medicaments.isNotEmpty) {
          return await getPharmaciesGardeProduits(medicaments);
        } else {
          return await getPharmaciesGarde();
        }
      } else if (mentionsGarde) {
        return await getPharmaciesGarde();
      } else if (mentionsProduit) {
        List<String> medicaments = _extractMedicaments(userMessage);
        if (medicaments.isNotEmpty) {
          return await getPharmaciesAvecProduits(medicaments);
        }
      }
      return await getPharmacies();
    } catch (e) {
      return [];
    }
  }

  // Détecter la zone mentionnée dans le message
  String? _detecterZone(String message) {
    // Liste des quartiers/zones de Lomé
    List<String> zones = [
      'Lome', 'Tokoin', 'Be', 'Avenou', 'Agbalepedogan', 'Adidogome',
      'Agoe', 'Kegue', 'Baguida', 'Agoenyive', 'Atikoume', 'Akodessewa'
    ];
    
    String messageLower = message.toLowerCase();
    
    for (String zone in zones) {
      if (messageLower.contains(zone.toLowerCase())) {
        return zone;
      }
    }
    
    return null;
  }

  // Extraire les noms de médicaments du message
  List<String> _extractMedicaments(String message) {
    // Liste de médicaments courants
    List<String> medicamentsConnus = [
      'paracetamol', 'aspirine', 'ibuprofene', 'doliprane', 'efferalgan',
      'amoxicilline', 'augmentin', 'omeprazole', 'metformine', 'insuline'
    ];
    
    String messageLower = message.toLowerCase();
    List<String> medicamentsTrouves = [];
    
    for (String med in medicamentsConnus) {
      if (messageLower.contains(med.toLowerCase())) {
        medicamentsTrouves.add(med);
      }
    }
    
    return medicamentsTrouves;
  }
}
