import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/gardes.dart';

class GardeRepository {
  final String apiUrl = 'https://miabe-pharmacie-api.onrender.com/api/pharmacies/garde/proches';

  Future<List<Garde>> fetchGardes(double latitude, double longitude) async {
    try {
      // Effectuez la requête GET à l'API avec les paramètres de latitude et longitude
      final response = await http.get(Uri.parse('$apiUrl?latitude=$latitude&longitude=$longitude'));

      // Vérifiez si la requête a réussi
      if (response.statusCode == 200) {
        // Analysez la réponse JSON
        List<dynamic> data = json.decode(response.body);
        // Convertissez les données en une liste d'objets Garde
        return data.map((json) => Garde.fromJson(json)).toList();
      } else {
        // Lancez une exception en cas d'échec de la requête
        throw Exception('Failed to load gardes: ${response.statusCode}');
      }
    } catch (e) {
      // Gérez les erreurs potentielles
      throw Exception('Error fetching gardes: $e');
    }
  }
}
