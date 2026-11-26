/// Une lecture enregistrée (table Historique_Visionnage).
/// Saison et épisode valent 0 pour un film.
class EntreeHistorique {
  final String titre;
  final int saison;
  final int episode;
  final DateTime vuLe;

  /// Nombre d'épisodes de la série connus au moment de la lecture.
  final int episodesConnus;

  const EntreeHistorique(
      {required this.titre,
      this.saison = 0,
      this.episode = 0,
      required this.vuLe,
      this.episodesConnus = 0});

  bool get estFilm => saison == 0 && episode == 0;
}

/// Où en est l'utilisateur sur une œuvre.
class SuiviOeuvre {
  final String titre;
  final DateTime derniereLecture;

  /// Épisode lu le plus récemment (null pour un film).
  final (int saison, int episode)? dernierLu;

  /// Épisode qui suit [dernierLu] (null : film, ou série terminée).
  final (int saison, int episode)? prochain;

  /// Épisodes ajoutés depuis la dernière lecture.
  final int nouveaux;

  /// Part des épisodes connus déjà lancés, entre 0 et 1 (null pour un film).
  final double? progression;

  /// Épisodes déjà lancés, pour les marquer « vu ».
  final Set<(int, int)> vus;

  const SuiviOeuvre({
    required this.titre,
    required this.derniereLecture,
    this.dernierLu,
    this.prochain,
    this.nouveaux = 0,
    this.progression,
    this.vus = const {},
  });

  bool get aNouveaute => nouveaux > 0;
}

/// Calculs sur l'historique. Logique pure, testée dans
/// test/suivi_visionnage_test.dart.
class SuiviVisionnage {
  /// [episodesParTitre] : saison → épisodes triés, pour chaque série.
  static Map<String, SuiviOeuvre> calculer(
    Iterable<EntreeHistorique> historique,
    Map<String, Map<int, List<int>>> episodesParTitre,
  ) {
    final parTitre = <String, List<EntreeHistorique>>{};
    for (final e in historique) {
      parTitre.putIfAbsent(e.titre, () => []).add(e);
    }

    final resultat = <String, SuiviOeuvre>{};
    parTitre.forEach((titre, entrees) {
      entrees.sort((a, b) => b.vuLe.compareTo(a.vuLe)); // plus récente d'abord
      final derniere = entrees.first;
      final episodes = episodesParTitre[titre] ?? const <int, List<int>>{};
      final total = episodes.values.fold<int>(0, (n, eps) => n + eps.length);

      if (derniere.estFilm) {
        resultat[titre] =
            SuiviOeuvre(titre: titre, derniereLecture: derniere.vuLe);
        return;
      }

      final existants = {
        for (final s in episodes.keys)
          for (final e in episodes[s]!) (s, e)
      };
      final vus = {
        for (final e in entrees)
          if (!e.estFilm) (e.saison, e.episode)
      };
      final dernierLu = (derniere.saison, derniere.episode);
      resultat[titre] = SuiviOeuvre(
        titre: titre,
        derniereLecture: derniere.vuLe,
        dernierLu: dernierLu,
        prochain: suivant(episodes, dernierLu.$1, dernierLu.$2),
        nouveaux: total > derniere.episodesConnus && derniere.episodesConnus > 0
            ? total - derniere.episodesConnus
            : 0,
        progression:
            total == 0 ? null : vus.intersection(existants).length / total,
        vus: vus,
      );
    });
    return resultat;
  }

  /// Épisode suivant : le suivant dans la saison, sinon le premier de la
  /// saison suivante, sinon null (fin de la série connue).
  static (int, int)? suivant(
      Map<int, List<int>> episodes, int saison, int episode) {
    final saisons = episodes.keys.toList()..sort();
    for (final s in saisons) {
      for (final e in [...episodes[s]!]..sort()) {
        if (s > saison || (s == saison && e > episode)) return (s, e);
      }
    }
    return null;
  }
}
