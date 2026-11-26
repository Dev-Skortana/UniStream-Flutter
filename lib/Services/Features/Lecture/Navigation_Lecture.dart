/// Une source de lecture trouvée par la recherche de liens.
class SourceLecture {
  final String site;
  final String lien;
  const SourceLecture({required this.site, required this.lien});

  /// « anime-sama.to » ; le lien entier s'il n'est pas une URL valide.
  String get domaine {
    final hote = Uri.tryParse(lien)?.host ?? '';
    return hote.isEmpty ? lien : hote;
  }
}

/// Logique pure de la feuille de lecture (aucun widget, aucune base) :
/// testée dans test/navigation_lecture_test.dart.
class NavigationLecture {
  /// Convertit le résultat de ResultLinkWatchOfVideo ({Name_Site, Link})
  /// en sources, sans lien vide ni doublon de lien.
  static List<SourceLecture> sources(List<Map<String, String>> resultats) {
    final vus = <String>{};
    return [
      for (final r in resultats)
        if ((r['Link'] ?? '').trim() case final lien
            when lien.isNotEmpty && vus.add(lien))
          SourceLecture(
              site: (r['Name_Site'] ?? '').trim().isEmpty
                  ? 'Source'
                  : r['Name_Site']!.trim(),
              lien: lien),
    ];
  }

  /// Index de la source à présélectionner : la dernière utilisée si elle
  /// fait partie des résultats (nom comparé sans casse), sinon la première.
  static int sourceParDefaut(List<SourceLecture> sources, String? derniere) {
    if (derniere == null) return 0;
    final i = sources.indexWhere(
        (s) => s.site.toLowerCase() == derniere.trim().toLowerCase());
    return i < 0 ? 0 : i;
  }

  /// Tous les épisodes, dans l'ordre de visionnage (saison puis épisode).
  static List<(int, int)> ordre(Map<int, List<int>> episodesParSaison) {
    final saisons = episodesParSaison.keys.toList()..sort();
    return [
      for (final s in saisons)
        for (final e in [...episodesParSaison[s]!]..sort()) (s, e)
    ];
  }

  /// Épisode précédent (-1) ou suivant (+1), en passant d'une saison à
  /// l'autre ; null au début ou à la fin, ou si l'épisode est inconnu.
  static (int, int)? voisin(
      Map<int, List<int>> episodesParSaison, (int, int) courant, int sens) {
    final liste = ordre(episodesParSaison);
    final i = liste.indexOf(courant);
    if (i < 0) return null;
    final j = i + sens;
    return j >= 0 && j < liste.length ? liste[j] : null;
  }

  /// Épisodes strictement avant [courant] (pour « vus jusqu'à … »).
  static List<(int, int)> avant(
      Map<int, List<int>> episodesParSaison, (int, int) courant) {
    final liste = ordre(episodesParSaison);
    final i = liste.indexOf(courant);
    return i <= 0 ? const [] : liste.sublist(0, i);
  }
}
