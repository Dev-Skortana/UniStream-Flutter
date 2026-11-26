import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thème choisi par l'utilisateur (clair, sombre ou celui du téléphone),
/// partagé par tous les écrans et conservé entre deux lancements.
///
/// Un seul objet, placé au-dessus de MaterialApp : quand sa valeur change,
/// MaterialApp se reconstruit et tous les écrans ouverts suivent.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._(super.mode);

  static const String _cle = 'theme_mode';

  /// Lit le choix enregistré ; « Système » par défaut (première ouverture).
  static Future<ThemeController> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final nom = prefs.getString(_cle);
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == nom,
      orElse: () => ThemeMode.system,
    );
    return ThemeController._(mode);
  }

  Future<void> choisir(ThemeMode mode) async {
    if (mode == value) return;
    value = mode; // l'affichage change tout de suite
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cle, mode.name);
  }
}
