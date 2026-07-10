import 'package:pharmacie_flutter/domaine/login/models/user_model.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus status;
  final AuthResponseDto? data;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.data,
    this.errorMessage,
  });

  // Permet de cloner l'état en modifiant seulement certains paramètres
  AuthState copyWith({
    AuthStatus? status,
    AuthResponseDto? data,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}