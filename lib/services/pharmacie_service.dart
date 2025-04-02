import 'package:http/http.dart' as http;
import 'dart:convert';

class PharmacieService {
  static const String baseUrl = 'https://miabe-pharmacie-api.onrender.com/api';

  // Récupérer les pharmacies proches
  Future<List<dynamic>> getPharmaciesProches(double latitude, double longitude, {double rayon = 3.0, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pharmacies/proches?latitude=$latitude&longitude=$longitude&rayon=$rayon&limit=$limit'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des pharmacies : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau : $e');
    }
  }
}