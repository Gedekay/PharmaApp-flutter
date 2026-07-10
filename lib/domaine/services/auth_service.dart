import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pharmacie_flutter/domaine/login/models/user_model.dart';
// Importez vos models ici

class AuthService {
  // Remplacez par l'URL de votre API (ex: http://10.0.2.2:8000/api pour l'émulateur Android)
  static const String baseUrl = 'http://10.0.2.2:8000/api/auth';

  Future<AuthResponseDto> loginPharmacien(
    String name,
    String phoneNumber,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'name': name, 'phone_number': phoneNumber}),
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      return AuthResponseDto.fromJson(decodedData);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erreur lors de la connexion');
    }
  }
}
