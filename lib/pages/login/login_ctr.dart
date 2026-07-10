import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/domaine/login/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmacie_flutter/domaine/services/auth_service.dart';
import 'package:pharmacie_flutter/pages/login/login_state.dart';

class AuthPharmacienCtrl extends ChangeNotifier {
  final AuthService _authService = AuthService();

  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_session_data';

  AuthState _state = AuthState();
  AuthState get state => _state;

  Future<bool> checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString(_keyToken);
      final String? jsonString = prefs.getString(_keyUserData);

      if (token != null && jsonString != null) {
        final Map<String, dynamic> decodedJson = jsonDecode(jsonString);
        final authData = AuthResponseDto.fromJson(decodedJson);

        _state = _state.copyWith(status: AuthStatus.success, data: authData);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la session locale : $e');
    }
    return false;
  }

  Future<void> login(String name, String phoneNumber) async {
    // 1. On passe en mode chargement
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      // 2. Appel au service API
      final responseDto = await _authService.loginPharmacien(name, phoneNumber);

      // 3. Sauvegarde locale dans les SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, responseDto.token);
      // On encode l'objet en JSON string pour le stocker textuellement
      await prefs.setString(
        _keyUserData,
        jsonEncode({
          'role': responseDto.role,
          'token': responseDto.token,
          'user': {
            'id': responseDto.user.id,
            'name': responseDto.user.name,
            'email': responseDto.user.email,
          },
          'pharmacien': responseDto.pharmacien != null
              ? {
                  'id': responseDto.pharmacien!.id,
                  'Name': responseDto.pharmacien!.name,
                  'First_name': responseDto.pharmacien!.firstName,
                  'phone_number': responseDto.pharmacien!.phoneNumber,
                  'gender': responseDto.pharmacien!.gender,
                  'age': responseDto.pharmacien!.age,
                  'user_id': responseDto.pharmacien!.userId,
                }
              : null,
        }),
      );

      // 4. Succès ! On stocke les données dans l'état de l'application
      _state = _state.copyWith(status: AuthStatus.success, data: responseDto);
    } catch (e) {
      // 5. Gestion de l'erreur
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      notifyListeners();
    }
  }

  /// Déconnexion de l'utilisateur et nettoyage local
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);

    _state = AuthState();
    notifyListeners();
  }

  void resetState() {
    _state = AuthState();
    notifyListeners();
  }
}
