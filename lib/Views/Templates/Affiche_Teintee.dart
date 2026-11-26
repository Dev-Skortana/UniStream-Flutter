import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unistream/Views/Helpers/Couleurs_Affiches.dart';

/// Affiche d'une œuvre aux coins arrondis, avec une ombre teintée de sa
/// propre couleur (calculée en arrière-plan, l'ombre neutre s'affiche avant).
class AfficheTeintee extends StatelessWidget {
  final String chemin;
  final double rayon;

  /// 1 = vignette de rangée ; plus grand pour l'affiche en vedette.
  final double force;

  /// Largeur de décodage de l'image (px) : la taille affichée × densité.
  final int largeurDecodage;

  const AfficheTeintee({
    super.key,
    required this.chemin,
    this.rayon = 12,
    this.force = 1,
    this.largeurDecodage = 300,
  });

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final luminosite = Theme.of(context).brightness;
    final repli = Center(
        child: Icon(Icons.image_not_supported_outlined,
            color: couleurs.onSurfaceVariant));

    return FutureBuilder<Color?>(
      future: CouleursAffiches.de(chemin),
      initialData: CouleursAffiches.immediate(chemin),
      builder: (context, instantane) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: couleurs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(rayon),
          boxShadow:
              CouleursAffiches.ombres(instantane.data, luminosite, force: force),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(rayon),
          child: chemin.isEmpty
              ? repli
              : Image.file(
                  File(chemin),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  cacheWidth: largeurDecodage,
                  errorBuilder: (_, __, ___) => repli,
                ),
        ),
      ),
    );
  }
}
