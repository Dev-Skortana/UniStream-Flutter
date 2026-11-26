import 'package:flutter/material.dart' show TimeOfDay;

/// Ce que l'écran Détail affiche en plus du modèle Video : métadonnées
/// liées (tables Videos_Genres, Videos_Pays, Videos_Realisateurs) et,
/// pour une série, ses épisodes rangés par saison.
///
/// Logique pure (aucun accès base ni widget) : testée dans
/// test/infos_detail_test.dart.
class InfosDetail {
  final List<String> genres;
  final List<String> pays;
  final List<String> realisateurs;

  /// Saison → épisodes, triés et sans doublon. Vide pour un film.
  final Map<int, List<int>> episodesParSaison;

  const InfosDetail(
      {this.genres = const [],
      this.pays = const [],
      this.realisateurs = const [],
      this.episodesParSaison = const {}});

  List<int> get saisons => episodesParSaison.keys.toList();

  int get nombreEpisodes =>
      episodesParSaison.values.fold(0, (total, eps) => total + eps.length);

  List<int> episodesDe(int saison) => episodesParSaison[saison] ?? const [];

  /// Range des lignes (Saison, Episode) lues en base. Les colonnes peuvent
  /// revenir en texte ou en entier selon l'origine des données : on accepte
  /// les deux, et on ignore une ligne illisible plutôt que d'échouer.
  static Map<int, List<int>> rangerEpisodes(
      Iterable<(Object?, Object?)> lignes) {
    final parSaison = <int, Set<int>>{};
    for (final (saison, episode) in lignes) {
      final s = int.tryParse('${saison ?? ''}'.trim());
      final e = int.tryParse('${episode ?? ''}'.trim());
      if (s == null || e == null) continue;
      parSaison.putIfAbsent(s, () => <int>{}).add(e);
    }
    final saisons = parSaison.keys.toList()..sort();
    return {
      for (final s in saisons) s: (parSaison[s]!.toList()..sort()),
    };
  }

  /// Noms nettoyés : espaces retirés, vides et doublons supprimés
  /// (sans tenir compte de la casse), ordre d'origine conservé.
  static List<String> nettoyerNoms(Iterable<Object?> noms) {
    final vus = <String>{};
    final resultat = <String>[];
    for (final brut in noms) {
      final nom = '${brut ?? ''}'.trim();
      if (nom.isEmpty || !vus.add(nom.toLowerCase())) continue;
      resultat.add(nom);
    }
    return resultat;
  }

  /// « 24 min », « 1 h 30 », « 2 h » ; null si la durée est absente ou nulle.
  static String? formaterDuree(TimeOfDay? duree) {
    if (duree == null) return null;
    final h = duree.hour, m = duree.minute;
    if (h == 0 && m == 0) return null;
    if (h == 0) return '$m min';
    if (m == 0) return '$h h';
    return '$h h ${m.toString().padLeft(2, '0')}';
  }

  static const List<String> _mois = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet',
    'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];

  /// « 5 octobre 2015 » (sans dépendre du package intl).
  static String? formaterDate(DateTime? date) =>
      date == null ? null : '${date.day} ${_mois[date.month - 1]} ${date.year}';
}
