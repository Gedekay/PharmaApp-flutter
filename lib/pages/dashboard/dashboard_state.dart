
import 'package:pharmacie_flutter/domaine/dashboard/model/dashboard_model.dart';

class DashboardState {
  bool loading = false;

  DashboardModel? dashboard;

  String? error;

  DashboardState({this.loading = false, this.dashboard, this.error});
}
