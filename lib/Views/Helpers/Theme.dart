import 'package:flutter/material.dart';

/// Couleur de base de l'appli : Material 3 en dérive toute la palette
/// (clair et sombre), avec des contrastes vérifiés.
const Color couleurDeBase = Color(0xFF4355B9);

/// Police arrondie des titres (assets/fonts, déclarée dans pubspec.yaml).
/// Le texte courant reste en Roboto, plus lisible en petit.
const String policeTitres = 'MPLUSRounded1c';

ThemeData _construire(Brightness luminosite) {
  final schema = ColorScheme.fromSeed(
    seedColor: couleurDeBase,
    brightness: luminosite,
    // En sombre, un fond plus profond que le gris Material par défaut :
    // les affiches et leurs ombres colorées ressortent mieux.
    surface: luminosite == Brightness.dark ? const Color(0xFF0F1015) : null,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: schema);
  final t = base.textTheme;

  TextStyle? arrondi(TextStyle? style, FontWeight graisse) =>
      style?.copyWith(fontFamily: policeTitres, fontWeight: graisse);

  return base.copyWith(
    scaffoldBackgroundColor: schema.surface,
    textTheme: t.copyWith(
      headlineLarge: arrondi(t.headlineLarge, FontWeight.w800),
      headlineMedium: arrondi(t.headlineMedium, FontWeight.w800),
      headlineSmall: arrondi(t.headlineSmall, FontWeight.w800),
      titleLarge: arrondi(t.titleLarge, FontWeight.w700),
      titleMedium: arrondi(t.titleMedium, FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: schema.surface,
      foregroundColor: schema.onSurface,
      scrolledUnderElevation: 2,
      titleTextStyle: arrondi(t.titleLarge, FontWeight.w800)
          ?.copyWith(color: schema.onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: schema.surfaceContainer,
      indicatorColor: schema.secondaryContainer,
    ),
  );
}

final ThemeData lightMode = _construire(Brightness.light);
final ThemeData darkMode = _construire(Brightness.dark);
