import 'package:flutter/material.dart';

/// Couleur de base de l'appli : Material 3 en dérive toute la palette
/// (clair et sombre), avec des contrastes vérifiés.
const Color couleurDeBase = Color(0xFF4355B9);

ThemeData _construire(Brightness luminosite) {
  final schema = ColorScheme.fromSeed(
    seedColor: couleurDeBase,
    brightness: luminosite,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: schema,
    scaffoldBackgroundColor: schema.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: schema.surface,
      foregroundColor: schema.onSurface,
      scrolledUnderElevation: 2,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: schema.surfaceContainer,
      indicatorColor: schema.secondaryContainer,
    ),
  );
}

final ThemeData lightMode = _construire(Brightness.light);
final ThemeData darkMode = _construire(Brightness.dark);
