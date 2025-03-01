import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pharmacies.dart';

class PharmacieRepository {
  final String baseUrl = 'https://miabe-pharmacie-api.onrender.com/api/pharmacies';

  Future<List<Pharmacie>> fetchPharmaciesProches(double latitude, double longitude) async {
    final response = await http.get(Uri.parse('$baseUrl/proches?latitude=$latitude&longitude=$longitude'));
    return _handleResponse(response);
  }

  Future<List<Pharmacie>> fetchPharmaciesAvecProduits(double latitude, double longitude, List<String> produits) async {
    final produitsQuery = produits.join(",");
    final response = await http.get(Uri.parse('$baseUrl/avec-produits?latitude=$latitude&longitude=$longitude&produits=$produitsQuery'));
    return _handleResponse(response);
  }

  Future<List<Pharmacie>> fetchPharmaciesGardeAvecProduits(double latitude, double longitude, List<String> produits) async {
    final produitsQuery = produits.join(",");
    final response = await http.get(Uri.parse('$baseUrl/garde/produits?latitude=$latitude&longitude=$longitude&produits=$produitsQuery'));
    return _handleResponse(response);
  }

  Future<List<Pharmacie>> _handleResponse(http.Response response) async {
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Pharmacie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pharmacies: ${response.statusCode}');
    }
  }
}
