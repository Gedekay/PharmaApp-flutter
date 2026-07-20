import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:pharmacie_flutter/domaine/dashboard/model/dashboard_model.dart';

class DashboardService {
  final String baseUrl = "http://10.252.252.45:8000/api";

  Future<DashboardModel> getStats() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/dashbord'),

            headers: {
              "Accept": "application/json",

              "Content-Type": "application/json",
            },
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return DashboardModel.fromJson(body);
      }

      if (response.statusCode == 401) {
        throw Exception("Session expirée");
      }

      if (response.statusCode == 404) {
        throw Exception("Route dashboard introuvable");
      }

      throw Exception(
        body['message'] ??
            "Erreur chargement dashboard (${response.statusCode})",
      );
    } catch (e) {
      throw Exception("Impossible de charger le dashboard : $e");
    }
  }
}
