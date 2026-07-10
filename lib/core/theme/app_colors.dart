import 'package:flutter/material.dart';

class AppLightColors {
  // Vert Sarcelle / Teal (Principal)
  static const Color primary = Color(0xFF00796B);
  // Vert Sombre Profond / Deep Teal (Secondaire)
  static const Color secondary = Color(0xFF004D40);

  static const Color background = Colors.white;
  static const Color cardBackground = Color(
    0xFFF8F9FA,
  ); // Gris très clair et doux
  static const Color surface = Color(0xFFFFFFFF);

  static const Color text = Color(0xFF212529); // Moins agressif que le noir pur
  static const Color textSecondary = Color(0xFF6C757D); // Pour les sous-titres
  static const Color title = Color(0xFF111111);

  static const Color border = Color(0xFFE9ECEF);
  static const Color disabled = Color(0xFFCED4DA);

  // Couleurs de statut
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFA502);
  static const Color info = Color(0xFF1E90FF);
}

class AppDarkColors {
  // Couleurs adaptées et adoucies pour le mode sombre
  static const Color primary = Color(
    0xFF26A69A,
  ); // Teal plus clair pour le contraste
  static const Color secondary = Color(0xFF00796B);

  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color surface = Color(0xFF252525);

  static const Color text = Color(0xFFE4E6EB);
  static const Color textSecondary = Color(0xFFB0B3B8);
  static const Color title = Colors.white;

  static const Color border = Color(0xFF2D2D2D);
  static const Color disabled = Color(0xFF4E4E4E);

  static const Color success = Color(0xFF2BED79);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF41A5FF);
}
