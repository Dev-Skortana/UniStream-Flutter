import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unistream/Views/Helpers/Son_Demarrage.dart';
import 'package:unistream/Views/Helpers/Theme.dart';
import 'package:unistream/Views/MainWrapper.dart';
import 'package:unistream/Views/Splash/Logo_UniStream.dart';

/// Écran d'ouverture animé, qui prend le relais de l'écran natif.
///
/// Le premier affichage reproduit exactement l'écran natif (disque de 192 px
/// centré, même fond, sans les perles) : le passage de l'un à l'autre ne se voit
/// pas. Ensuite, en 1,5 s, calé sur le son (utils/son/generer_son_splash.py) :
///   0 s          frappe grave → le disque gonfle légèrement
///   0,20 / 0,35 / 0,50 s  les trois notes → les trois perles sortent du U
///   0,50 s       l'accord → halo et apparition du nom
///   1,5 s        fondu vers l'accueil (le son finit de s'éteindre derrière)
class ViewSplash extends StatefulWidget {
  const ViewSplash({super.key});

  @override
  State<ViewSplash> createState() => _ViewSplashState();
}

class _ViewSplashState extends State<ViewSplash> with SingleTickerProviderStateMixin {
  static const double _duree = 1.5; // secondes
  static const List<double> _notesPerles = [0.20, 0.35, 0.50];
  static const double _dureePerle = 0.24;
  static const double _debutAccord = 0.50;
  static const double _monteeAccord = 0.28;

  /// Diamètre du disque de l'écran natif : image de 768 px en densité ×4.
  static const double _diametre = 192;

  // Couleurs de l'écran natif (flutter_native_splash dans pubspec.yaml).
  static const Color _fondClair = Color(0xFFFBF8FF);
  static const Color _fondSombre = Color(0xFF0F1015);

  late final AnimationController _controleur = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_duree * 1000).round()),
  );
  bool _parti = false;

  @override
  void initState() {
    super.initState();
    // Après le premier affichage : le son et l'animation démarrent ensemble.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SonDemarrage>().jouer();
      if (MediaQuery.of(context).disableAnimations) {
        // « Réduire les animations » : image finale directement, courte pause.
        _controleur.value = 1;
        Future.delayed(const Duration(milliseconds: 900), _ouvrirAccueil);
      } else {
        _controleur.forward().then((_) => _ouvrirAccueil());
      }
    });
  }

  void _ouvrirAccueil() {
    if (_parti || !mounted) return;
    _parti = true;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const MainWrapper(),
      transitionsBuilder: (_, animation, __, enfant) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: enfant,
      ),
    ));
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  /// Avancement entre [debut] et [debut] + [duree] (en secondes), borné à 0..1.
  static double _phase(double t, double debut, double duree) =>
      ((t - debut) / duree).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    // Le fond suit le téléphone (comme l'écran natif, qui ne peut pas lire le
    // thème choisi dans l'appli) ; le fondu vers l'accueil fait la transition.
    final sombre = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final couleurTexte = sombre ? Colors.white : const Color(0xFF1B1B21);

    // Material (et pas un simple fond) : fournit le style de texte par défaut.
    return Material(
      color: sombre ? _fondSombre : _fondClair,
      child: Semantics(
        label: 'UniStream, ouverture',
        child: AnimatedBuilder(
          animation: _controleur,
          builder: (context, _) {
            final t = _controleur.value * _duree;
            final perles = [for (final note in _notesPerles) _phase(t, note, _dureePerle)];
            final impulsion = t < 0.25 ? math.sin(math.pi * t / 0.25) : 0.0;
            // Halo : monte avec l'accord, puis retombe doucement.
            final halo = Curves.easeOut.transform(_phase(t, _debutAccord, _monteeAccord)) *
                (1 - 0.4 * _phase(t, _debutAccord + _monteeAccord, 0.72));
            final nom = Curves.easeOutCubic.transform(_phase(t, _debutAccord + 0.05, 0.40));

            return Stack(
              alignment: Alignment.center,
              children: [
                // Halo violet derrière le disque.
                IgnorePointer(
                  child: Container(
                    width: _diametre * 1.9,
                    height: _diametre * 1.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        const Color(0xFF8A5CF6).withValues(alpha: (sombre ? 0.45 : 0.30) * halo),
                        const Color(0xFF8A5CF6).withValues(alpha: 0),
                      ]),
                    ),
                  ),
                ),
                // Disque, exactement au centre (comme l'écran natif).
                SizedBox.square(
                  dimension: _diametre,
                  child: CustomPaint(
                    painter: PeintreLogoUniStream(perles: perles, impulsion: impulsion),
                  ),
                ),
                // Nom, sous le disque : glisse et apparaît avec l'accord.
                Transform.translate(
                  offset: Offset(0, _diametre / 2 + 44 + 14 * (1 - nom)),
                  child: Opacity(
                    opacity: nom,
                    child: Text(
                      'UniStream',
                      style: TextStyle(
                        fontFamily: policeTitres,
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                        letterSpacing: 0.5,
                        color: couleurTexte,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
