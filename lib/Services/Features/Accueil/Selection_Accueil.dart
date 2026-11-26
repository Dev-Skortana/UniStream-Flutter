import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';

/// Une rangée horizontale de l'Accueil.
class RangeeAccueil {
  /// Petit libellé espacé au-dessus du titre (« RÉCENT », « ANIMES »…).
  final String surTitre;
  final String titre;
  final List<OeuvreBibliotheque> oeuvres;
  const RangeeAccueil(this.surTitre, this.titre, this.oeuvres);
}

class ContenuAccueil {
  final OeuvreBibliotheque? vedette;
  final List<RangeeAccueil> rangees;
  const ContenuAccueil(this.vedette, this.rangees);

  bool get estVide => vedette == null;
}

/// Compose l'Accueil à partir de la bibliothèque. Logique pure, testée dans
/// test/selection_accueil_test.dart.
class SelectionAccueil {
  static const int maxParRangee = 20;

  static ContenuAccueil composer(
    Iterable<OeuvreBibliotheque> toutes, {
    FamilleOeuvre? famille,
    required DateTime maintenant,
  }) {
    final triees = toutes
        .where((o) => famille == null || o.famille == famille)
        .toList()
      ..sort(FiltreBibliotheque.comparer); // plus récentes d'abord
    if (triees.isEmpty) return const ContenuAccueil(null, []);

    // En vedette : la plus récente qui a une affiche (sinon la plus récente).
    final vedette = triees.firstWhere((o) => o.lienAffiche.isNotEmpty,
        orElse: () => triees.first);

    final ilYaUnAn = maintenant.subtract(const Duration(days: 365));
    final recentes = triees
        .where((o) =>
            !identical(o, vedette) &&
            o.dateParution != null &&
            o.dateParution!.isAfter(ilYaUnAn))
        .take(maxParRangee)
        .toList();

    List<OeuvreBibliotheque> parmi(bool Function(OeuvreBibliotheque) test) =>
        triees.where(test).take(maxParRangee).toList();

    final rangees = <RangeeAccueil>[
      RangeeAccueil('RÉCENT', 'Parus ces 12 derniers mois', recentes),
      if (famille == null) ...[
        RangeeAccueil('ANIMES', 'Animes',
            parmi((o) => o.famille == FamilleOeuvre.anime)),
        RangeeAccueil('DRAMAS', 'Dramas',
            parmi((o) => o.famille == FamilleOeuvre.drama)),
        RangeeAccueil('LIVE ACTION', 'Séries et films',
            parmi((o) => o.famille == FamilleOeuvre.live)),
      ] else ...[
        RangeeAccueil('SÉRIES', 'Séries',
            parmi((o) => o.format == FormatOeuvre.serie)),
        RangeeAccueil('FILMS', 'Films',
            parmi((o) => o.format == FormatOeuvre.film)),
      ],
    ].where((r) => r.oeuvres.isNotEmpty).toList();

    return ContenuAccueil(vedette, rangees);
  }
}
