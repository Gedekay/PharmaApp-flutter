import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/domaine/dashboard/service/dashboard_service.dart';


import 'package:pharmacie_flutter/pages/dashboard/dashboard_state.dart';

class DashboardController extends ChangeNotifier {
  final DashboardService service;

  DashboardController({required this.service});

  DashboardState state = DashboardState();

  Future<void> loadDashboard() async {
    try {
      // Début chargement

      state.loading = true;

      state.error = null;

      notifyListeners();

      // Appel API

      final data = await service.getStats();

      // Mise à jour données

      state.dashboard = data;

      state.loading = false;

      notifyListeners();
    } catch (e) {
      state.loading = false;

      state.error = e.toString();

      notifyListeners();
    }
  }
}
