import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Logo UniStream dessiné en Dart : « le U qui se dissout en flux ».
///
/// Même géométrie que utils/logo/generer_assets_logo.py (repère 1024 × 1024) :
/// si on modifie l'une, modifier l'autre. Le cadrage est celui de l'écran natif
/// (disque dégradé, signe à 62 % de l'icône adaptative), pour que le passage de
/// l'écran natif à l'écran Flutter soit invisible.
class PeintreLogoUniStream extends CustomPainter {
  PeintreLogoUniStream({required this.perles, this.impulsion = 0});

  /// Avancement de chaque perle, de 0 (cachée dans le jambage) à 1 (en place).
  final List<double> perles;

  /// Léger gonflement du disque (0 à 1), sur la frappe du son.
  final double impulsion;

  static const _degradeFond = [Color(0xFF9C8CFF), Color(0xFFC79BF5), Color(0xFFFFA9C6)];
  static const _degradeLecture = [Color(0xFF4355B9), Color(0xFF8A5CF6)];
  static const _ombre = Color(0xFF5B3FC4);
  static const _opaciteOmbre = 0.35;

  /// (x, y, rayon, couleur) : pêche, menthe, beurre — une perle par famille.
  static const _perles = [
    (726.0, 306.0, 50.0, Color(0xFFFFC2A6)),
    (740.0, 196.0, 35.0, Color(0xFF9FEBD3)),
    (760.0, 116.0, 23.0, Color(0xFFFFE596)),
  ];

  /// Haut du jambage droit : point de départ des perles.
  static const _sortiePerles = Offset(724, 430);

  /// Signe 62 % de l'icône, vu dans les 72 dp centraux sur 108 : 0,62 × 108 / 72.
  static const _echelleSigne = 0.62 * 108 / 72;

  static final Path _u = Path()
    ..moveTo(300, 270)
    ..lineTo(300, 560)
    ..arcToPoint(const Offset(724, 560), radius: const Radius.circular(212), clockwise: false)
    ..lineTo(724, 430);

  static final Path _lecture = Path()
    ..moveTo(452, 412)
    ..lineTo(452, 608)
    ..lineTo(602, 510)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final cote = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - cote) / 2, (size.height - cote) / 2);
    canvas.scale(cote / 1024);

    // Impulsion de la frappe : le disque gonfle de 3,5 % puis revient.
    final gonflement = 1 + 0.035 * impulsion;
    canvas.translate(512, 512);
    canvas.scale(gonflement);
    canvas.translate(-512, -512);

    // Disque : le dégradé de l'icône (1024 px) vu à travers un cercle de 683 px,
    // d'où des bornes à ±1,5 au lieu de ±1.
    const disque = Rect.fromLTWH(0, 0, 1024, 1024);
    canvas.drawCircle(
      const Offset(512, 512),
      512,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment(-1.5, -1.5),
          end: Alignment(1.5, 1.5),
          colors: _degradeFond,
          stops: [0, 0.6, 1],
        ).createShader(disque),
    );

    // Signe : recentré (décalage vertical de 34) puis réduit.
    canvas.translate(512, 512);
    canvas.scale(_echelleSigne);
    canvas.translate(-512, -478);

    // Ombre portée teintée, sous le U et le bouton lecture. Dessinée opaque dans
    // un calque, puis le calque entier est posé à 35 % : les formes qui se
    // chevauchent ne foncent pas (même rendu que le filtre SVG d'origine).
    canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, _opaciteOmbre));
    canvas.translate(0, 18);
    Paint ombre() => Paint()
      ..color = _ombre
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawPath(_u, _trait(ombre(), 128));
    canvas.drawPath(_lecture, ombre());
    canvas.drawPath(_lecture, _trait(ombre(), 44));
    canvas.restore();

    canvas.drawPath(_u, _trait(Paint()..color = Colors.white, 128));

    final degradeLecture = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _degradeLecture,
    ).createShader(const Rect.fromLTRB(452, 412, 602, 608));
    canvas.drawPath(_lecture, Paint()..shader = degradeLecture);
    canvas.drawPath(_lecture, _trait(Paint()..shader = degradeLecture, 44));

    // Perles : elles sortent du jambage droit et montent à leur place.
    for (var i = 0; i < _perles.length && i < perles.length; i++) {
      final p = perles[i].clamp(0.0, 1.0);
      if (p == 0) continue;
      final (x, y, r, couleur) = _perles[i];
      final position = Offset.lerp(_sortiePerles, Offset(x, y), Curves.easeOutBack.transform(p))!;
      final rayon = r * (0.35 + 0.65 * Curves.easeOut.transform(p));
      final opacite = math.min(1.0, p * 3);
      canvas.drawCircle(position, rayon, Paint()..color = couleur.withValues(alpha: opacite));
    }

    canvas.restore();
  }

  static Paint _trait(Paint p, double epaisseur) => p
    ..style = PaintingStyle.stroke
    ..strokeWidth = epaisseur
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(PeintreLogoUniStream ancien) =>
      ancien.impulsion != impulsion || !_memesValeurs(ancien.perles, perles);

  static bool _memesValeurs(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
