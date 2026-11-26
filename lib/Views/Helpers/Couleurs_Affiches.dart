import 'dart:io';

import 'package:flutter/material.dart';

/// Couleur dominante de chaque affiche, pour teinter ombres et dégradés.
///
/// Calculée par Flutter (ColorScheme.fromImageProvider, qui réduit l'image
/// avant de l'analyser), une seule fois par affiche et par lancement :
/// le résultat est gardé en mémoire, et les appels simultanés pour la même
/// affiche partagent le même calcul.
///
/// Piste si c'est encore trop lent sur un vieux téléphone : stocker la couleur
/// en base au téléchargement de l'affiche (une colonne de plus dans Videos).
class CouleursAffiches {
  static final Map<String, Future<Color?>> _cache = {};

  static Future<Color?> de(String chemin) {
    if (chemin.isEmpty) return Future.value(null);
    return _cache.putIfAbsent(chemin, () => _calculer(chemin));
  }

  /// Valeur déjà connue, sans attendre (null si pas encore calculée).
  static Color? immediate(String chemin) => _connues[chemin];
  static final Map<String, Color?> _connues = {};

  static Future<Color?> _calculer(String chemin) async {
    try {
      final fichier = File(chemin);
      if (!await fichier.exists()) return null;
      final schema = await ColorScheme.fromImageProvider(
        provider: ResizeImage(FileImage(fichier), width: 64),
        brightness: Brightness.light,
      );
      // primary d'un schéma clair : teinte saturée de ton moyen,
      // lisible comme lueur sur fond sombre comme sur fond clair.
      return _connues[chemin] = schema.primary;
    } catch (_) {
      return _connues[chemin] = null;
    }
  }

  /// Ombres d'une vignette : une ombre courte neutre pour le relief,
  /// une ombre diffuse de la couleur de l'affiche pour la lueur.
  static List<BoxShadow> ombres(Color? teinte, Brightness luminosite,
      {double force = 1}) {
    final sombre = luminosite == Brightness.dark;
    final lueur = (teinte ?? (sombre ? Colors.black : const Color(0xFF1B1B21)))
        .withValues(alpha: (sombre ? 0.7 : 0.45) * force);
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: sombre ? 0.45 : 0.12),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: lueur,
        blurRadius: 22 * force,
        offset: Offset(0, 10 * force),
        spreadRadius: -8,
      ),
    ];
  }
}
