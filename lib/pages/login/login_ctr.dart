import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pharmacie_flutter/domaine/login/models/user_model.dart';
import 'package:pharmacie_flutter/domaine/services/auth_service.dart';
import 'package:pharmacie_flutter/pages/login/login_state.dart';

class AuthPharmacienCtrl extends ChangeNotifier {
  final AuthService _authService = AuthService();

  static const String _keyToken = 'auth_token';
  static const String _keyUserData = 'user_session_data';

  AuthState _state = AuthState();

  AuthState get state => _state;

  /// ===========================
  /// Getters
  /// ===========================

  AuthResponseDto? get auth => _state.data;

  User? get user => _state.data?.user;

  Pharmacien? get pharmacien => _state.data?.pharmacien;

  bool get isLoggedIn =>
      _state.status == AuthStatus.success && _state.data != null;

  String get fullName {
    if (_state.data?.pharmacien != null) {
      return "${_state.data!.pharmacien!.firstName} ${_state.data!.pharmacien!.name}";
    }

    return _state.data?.user.name ?? "";
  }

  /// ===========================
  /// Vérifie la session locale
  /// ===========================

  Future<bool> checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(_keyToken);
      final jsonString = prefs.getString(_keyUserData);

      if (token != null && jsonString != null) {
        final decodedJson = jsonDecode(jsonString);

        final authData = AuthResponseDto.fromJson(decodedJson);

        _state = _state.copyWith(status: AuthStatus.success, data: authData);

        notifyListeners();

        return true;
      }
    } catch (e) {
      debugPrint("Erreur Auto Login : $e");
    }

    return false;
  }

  /// ===========================
  /// Connexion
  /// ===========================

  Future<void> login(String name, String phoneNumber) async {
    _state = _state.copyWith(status: AuthStatus.loading, errorMessage: null);

    notifyListeners();

    try {
      final responseDto = await _authService.loginPharmacien(name, phoneNumber);

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyToken, responseDto.token);

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

      _state = _state.copyWith(status: AuthStatus.success, data: responseDto);
    } catch (e) {
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }

    notifyListeners();
  }

  /// ===========================
  /// Déconnexion
  /// ===========================

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);

    _state = AuthState();

    notifyListeners();
  }

  /// ===========================
  /// Réinitialiser l'état
  /// ===========================

  void resetState() {
    _state = AuthState();

    notifyListeners();
  }
}
