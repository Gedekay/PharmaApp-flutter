import 'package:pharmacie_flutter/domaine/produit/models/produit_model.dart';

class ProduitState {
  bool loading;

  String? error;

  List<ProduitModel> produits;

  ProduitState({this.loading = false, this.error, this.produits = const []});

  ProduitState copyWith({
    bool? loading,

    String? error,

    List<ProduitModel>? produits,
  }) {
    return ProduitState(
      loading: loading ?? this.loading,

      error: error,

      produits: produits ?? this.produits,
    );
  }
}
