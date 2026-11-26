import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Historique/Suivi_Visionnage.dart';

/// Une rangée horizontale de l'Accueil.
class RangeeAccueil {
  /// Petit libellé espacé au-dessus du titre (« RÉCENT », « ANIMES »…).
  final String surTitre;
  final String titre;
  final List<OeuvreBibliotheque> oeuvres;

  /// Texte sous certaines affiches (titre → légende), ex. « S1 · É5 ».
  final Map<String, String> legendes;

  const RangeeAccueil(this.surTitre, this.titre, this.oeuvres,
      {this.legendes = const {}});
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
    Map<String, SuiviOeuvre> suivis = const {},
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

    // « Reprendre » : séries commencées dont un épisode suit le dernier lu,
    // la plus récemment regardée d'abord.
    final enCours = triees
        .where((o) => suivis[o.titre]?.prochain != null)
        .toList()
      ..sort((a, b) => suivis[b.titre]!
          .derniereLecture
          .compareTo(suivis[a.titre]!.derniereLecture));
    final aReprendre = enCours.take(maxParRangee).toList();

    final rangees = <RangeeAccueil>[
      RangeeAccueil('REPRENDRE', 'Continuer à regarder', aReprendre,
          legendes: {
            for (final o in aReprendre)
              o.titre: 'S${suivis[o.titre]!.prochain!.$1} · '
                  'É${suivis[o.titre]!.prochain!.$2}',
          }),
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
