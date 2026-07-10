import 'package:flutter/material.dart';
import 'package:pharmacie_flutter/pages/login/login_ctr.dart';
import 'package:pharmacie_flutter/pages/splash/splash_view.dart';
import 'package:provider/provider.dart';

import 'package:pharmacie_flutter/pages/login/login_pharmacien_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthPharmacienCtrl())],
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
      themeMode: ThemeMode.system, // automatique selon le téléphone
      home: const PharmaSplashView(),
    );
  }
}
