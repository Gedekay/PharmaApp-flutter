// historique_controller.dart
import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/domaine/vente/services/vente_service.dart';
import 'package:pharmacie_flutter/domaine/vente/models/vente_model.dart';

class HistoriqueController extends ChangeNotifier {
  final VenteService service;

  HistoriqueController({required this.service});

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<VenteModel> _ventes = [];
  List<VenteModel> get ventes => _ventes;

  List<VenteModel> _filteredVentes = [];
  List<VenteModel> get filteredVentes => _filteredVentes;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  String _filterType = 'all'; // all, today, week, month
  String get filterType => _filterType;

  Future<void> loadVentes() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final data = await service.getAll();
      _ventes = data;
      _applyFilters();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByDate(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
    notifyListeners();
  }

  void filterByType(String type) {
    _filterType = type;
    _startDate = null;
    _endDate = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredVentes = _ventes.where((vente) {
      // Filtre de recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch =
            vente.clientName.toLowerCase().contains(query) ||
            vente.factureNumero.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Filtre de date
      if (_startDate != null && _endDate != null) {
        if (vente.createdAt == null) return false;
        final date = vente.createdAt!;
        return date.isAfter(_startDate!) &&
            date.isBefore(_endDate!.add(const Duration(days: 1)));
      }

      // Filtre par type
      switch (_filterType) {
        case 'today':
          if (vente.createdAt == null) return false;
          return vente.createdAt!.isAfter(
            DateTime.now().subtract(const Duration(days: 1)),
          );
        case 'week':
          if (vente.createdAt == null) return false;
          return vente.createdAt!.isAfter(
            DateTime.now().subtract(const Duration(days: 7)),
          );
        case 'month':
          if (vente.createdAt == null) return false;
          return vente.createdAt!.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          );
        default:
          return true;
      }
    }).toList();

    // Trier par date décroissante
    _filteredVentes.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });

    notifyListeners();
  }

  double get totalCA {
    return _filteredVentes.fold(0, (sum, vente) => sum + vente.total);
  }

  int get totalVentes {
    return _filteredVentes.length;
  }

  int get totalArticles {
    return _filteredVentes.fold(0, (sum, vente) {
      return sum + vente.details.fold(0, (s, detail) => s + detail.quantite);
    });
  }

  void clearFilters() {
    _searchQuery = '';
    _startDate = null;
    _endDate = null;
    _filterType = 'all';
    _applyFilters();
    notifyListeners();
  }
}
