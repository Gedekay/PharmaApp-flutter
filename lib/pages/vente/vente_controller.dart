import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/domaine/vente/models/create_vente_dto.dart';
import 'package:pharmacie_flutter/domaine/vente/models/vente_model.dart';
import 'package:pharmacie_flutter/domaine/vente/services/vente_service.dart';
import 'package:pharmacie_flutter/pages/vente/vente_state.dart';

class VenteController extends ChangeNotifier {
  final VenteService service;

  VenteController({required this.service});
  VenteState _state = VenteState();

  VenteState get state => _state;

  Future<void> loadVentes() async {
    try {
      _state = _state.copyWith(loading: true, error: null);
      notifyListeners();

      final data = await service.getAll();
      _state = _state.copyWith(loading: false, ventes: data);
    } catch (e) {
      _state = _state.copyWith(loading: false, error: e.toString());
    }
    notifyListeners();
  }

  Future<void> loadVente(int id) async {
    try {
      _state = _state.copyWith(loading: true, error: null);
      notifyListeners();

      final data = await service.getById(id);

      // ✅ Vérifier si les détails sont chargés
      if (data.details.isEmpty) {
        print("⚠️ Attention: La vente $id n'a pas de détails");
      }

      _state = _state.copyWith(loading: false, selectedVente: data);
    } catch (e) {
      _state = _state.copyWith(loading: false, error: e.toString());
    }
    notifyListeners();
  }

  Future<VenteModel?> createVente(CreateVenteDto dto) async {
    try {
      _state = _state.copyWith(saving: true, error: null);
      notifyListeners();

      final vente = await service.create(dto);

      // ✅ Vérifier que la vente a des détails
      if (vente.details.isEmpty) {
        print("⚠️ Attention: La vente créée n'a pas de détails");
        // 🔄 Essayer de recharger la vente
        try {
          final rechargedVente = await service.getById(vente.id);
          _state = _state.copyWith(
            saving: false,
            selectedVente: rechargedVente,
          );
          await loadVentes();
          return rechargedVente;
        } catch (e) {
          print("❌ Impossible de recharger la vente: $e");
          _state = _state.copyWith(saving: false, selectedVente: vente);
          await loadVentes();
          return vente;
        }
      }

      _state = _state.copyWith(saving: false, selectedVente: vente);
      await loadVentes();
      return vente;
    } catch (e) {
      _state = _state.copyWith(saving: false, error: e.toString());
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateVente({required int id, required double total}) async {
    try {
      await service.update(id: id, total: total);
      await loadVentes();
      return true;
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVente(int id) async {
    try {
      await service.delete(id);
      await loadVentes();
      return true;
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      return false;
    }
  }
}
