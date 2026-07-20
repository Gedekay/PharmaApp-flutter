import 'package:flutter/material.dart';

import 'package:pharmacie_flutter/domaine/produit/services/produit_service.dart';

import 'package:pharmacie_flutter/pages/produit/produit_state.dart';

class ProduitController extends ChangeNotifier {
  final ProduitService service;

  ProduitController({required this.service});

  ProduitState _state = ProduitState();

  ProduitState get state => _state;

  Future<void> loadProduits() async {
    try {
      _state = _state.copyWith(loading: true, error: null);

      notifyListeners();

      final data = await service.getAll();

      _state = _state.copyWith(loading: false, produits: data);
    } catch (e) {
      _state = _state.copyWith(loading: false, error: e.toString());
    }

    notifyListeners();
  }
}
