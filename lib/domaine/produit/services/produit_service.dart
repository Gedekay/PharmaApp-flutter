import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacie_flutter/domaine/produit/models/produit_model.dart';

class ProduitService {
  final String baseUrl = "http://10.252.252.45:8000/api";

  Future<List<ProduitModel>> getAll() async {
    final response = await http.get(
      Uri.parse("$baseUrl/produits"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      final List data = jsonResponse['data'] ?? [];

      return data.map((e) => ProduitModel.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement produits: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> getAllWithPagination() async {
    final response = await http.get(
      Uri.parse("$baseUrl/produits"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      return {
        'produits': (jsonResponse['data'] as List)
            .map((e) => ProduitModel.fromJson(e))
            .toList(),
        'meta': jsonResponse['meta'],
      };
    } else {
      throw Exception("Erreur chargement produits: ${response.statusCode}");
    }
  }

  Future<List<ProduitModel>> search(String query) async {
    final response = await http.get(
      Uri.parse("$baseUrl/produits?search=$query"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List data = jsonResponse['data'] ?? [];
      return data.map((e) => ProduitModel.fromJson(e)).toList();
    } else {
      throw Exception("Erreur de recherche: ${response.statusCode}");
    }
  }
}
