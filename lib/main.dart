import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/pages/historique_vente/historique_controller.dart';
import 'package:pharmacie_flutter/pages/historique_vente/historique_vente_page.dart';
import 'package:provider/provider.dart';

import 'package:pharmacie_flutter/domaine/dashboard/service/dashboard_service.dart';
import 'package:pharmacie_flutter/domaine/produit/services/produit_service.dart';
import 'package:pharmacie_flutter/domaine/vente/services/vente_service.dart';

import 'package:pharmacie_flutter/pages/login/login_ctr.dart';
import 'package:pharmacie_flutter/pages/splash/splash_view.dart';
import 'package:pharmacie_flutter/pages/produit/produit_controller.dart';
import 'package:pharmacie_flutter/pages/vente/vente_controller.dart';
import 'package:pharmacie_flutter/pages/dashboard/dashboard_controller.dart';

import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthPharmacienCtrl()),

        ChangeNotifierProvider(
          create: (_) => ProduitController(service: ProduitService()),
        ),

        ChangeNotifierProvider(
          create: (_) => VenteController(service: VenteService()),
        ),

        ChangeNotifierProvider(
          create: (_) => DashboardController(service: DashboardService()),
        ),

        ChangeNotifierProvider(
          create: (_) => HistoriqueController(service: VenteService()),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: ThemeMode.system,

      home: const PharmaSplashView(),

      routes: {'/historique': (context) => const HistoriqueVentePage()},
    );
  }
}
