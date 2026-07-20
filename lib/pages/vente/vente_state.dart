import 'package:pharmacie_flutter/domaine/vente/models/vente_model.dart';

class VenteState {
  bool loading;

  bool saving;

  String? error;

  List<VenteModel> ventes;

  VenteModel? selectedVente;

  VenteState({
    this.loading = false,

    this.saving = false,

    this.error,

    this.ventes = const [],

    this.selectedVente,
  });

  VenteState copyWith({
    bool? loading,

    bool? saving,

    String? error,

    List<VenteModel>? ventes,

    VenteModel? selectedVente,
  }) {
    return VenteState(
      loading: loading ?? this.loading,

      saving: saving ?? this.saving,

      error: error,

      ventes: ventes ?? this.ventes,

      selectedVente: selectedVente ?? this.selectedVente,
    );
  }
}
