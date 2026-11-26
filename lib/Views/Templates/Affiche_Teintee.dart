import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unistream/Views/Helpers/Couleurs_Affiches.dart';
import 'package:unistream/Views/Helpers/Theme.dart';

/// Affiche d'une œuvre aux coins arrondis, avec une ombre teintée de sa
/// propre couleur (calculée en arrière-plan, l'ombre neutre s'affiche avant).
class AfficheTeintee extends StatelessWidget {
  final String chemin;
  final double rayon;

  /// 1 = vignette de rangée ; plus grand pour l'affiche en vedette.
  final double force;

  /// Largeur de décodage de l'image (px) : la taille affichée × densité.
  final int largeurDecodage;

  /// Pastille en haut à gauche (ex. « Nouvel ép. »), absente si null.
  final String? badge;

  /// Barre « vu » en bas de l'affiche (0 à 1), absente si null ou 0.
  final double? progression;

  const AfficheTeintee({
    super.key,
    required this.chemin,
    this.rayon = 12,
    this.force = 1,
    this.largeurDecodage = 300,
    this.badge,
    this.progression,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              chemin.isEmpty
                  ? repli
                  : Image.file(
                      File(chemin),
                      fit: BoxFit.cover,
                      cacheWidth: largeurDecodage,
                      errorBuilder: (_, __, ___) => repli,
                    ),
              if (badge != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _Pastille(texte: badge!),
                ),
              if ((progression ?? 0) > 0)
                Positioned(
                  left: 6,
                  right: 6,
                  bottom: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progression!.clamp(0.0, 1.0),
                      minHeight: 3,
                      color: couleurs.primary,
                      backgroundColor: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille pastel arrondie posée sur une affiche.
class _Pastille extends StatelessWidget {
  final String texte;
  const _Pastille({required this.texte});

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: couleurs.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texte,
        style: TextStyle(
          fontFamily: policeTitres,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          color: couleurs.onTertiaryContainer,
        ),
      ),
    );
  }
}
