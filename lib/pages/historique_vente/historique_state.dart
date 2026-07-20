import 'package:pharmacie_flutter/domaine/vente/models/vente_model.dart';

class HistoriqueState {
  final bool loading;
  final String? error;
  final List<VenteModel> ventes;
  final List<VenteModel> filteredVentes;
  final String searchQuery;
  final String filterType;
  final DateTime? startDate;
  final DateTime? endDate;

  HistoriqueState({
    this.loading = false,
    this.error,
    this.ventes = const [],
    this.filteredVentes = const [],
    this.searchQuery = '',
    this.filterType = 'all',
    this.startDate,
    this.endDate,
  });

  HistoriqueState copyWith({
    bool? loading,
    String? error,
    List<VenteModel>? ventes,
    List<VenteModel>? filteredVentes,
    String? searchQuery,
    String? filterType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return HistoriqueState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      ventes: ventes ?? this.ventes,
      filteredVentes: filteredVentes ?? this.filteredVentes,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
