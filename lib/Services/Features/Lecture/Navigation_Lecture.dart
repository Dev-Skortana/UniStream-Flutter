/// D'où viennent les sources affichées.
enum ProvenanceSources { serveur, telephone }

/// Une source de lecture trouvée par la recherche de liens.
class SourceLecture {
  final String site;
  final String lien;

  /// Requête XPath d'épisode fournie par le serveur ("" : la page est déjà
  /// celle de l'épisode). null : à calculer par le package (recherche faite
  /// sur le téléphone), d'après le domaine du lien.
  final String? requete;

  /// « VF », « VOSTFR »… (vide si inconnue ou recherche du téléphone).
  final List<String> langues;

  const SourceLecture(
      {required this.site,
      required this.lien,
      this.requete,
      this.langues = const []});

  /// « anime-sama.to » ; le lien entier s'il n'est pas une URL valide.
  String get domaine {
    final hote = Uri.tryParse(lien)?.host ?? '';
    return hote.isEmpty ? lien : hote;
  }
}

/// Un site interrogé par le serveur qui n'a pas de lien à proposer.
class SiteSansLien {
  final String site;

  /// « absent » (page lue, épisode absent) ou « injoignable ».
  final String statut;
  const SiteSansLien(this.site, this.statut);

  String get libelle => statut == 'injoignable' ? '$site injoignable' : '$site : absent';
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

  /// Réponse de GET /v1/oeuvres/{id}/liens → sources prêtes à lire, et sites
  /// sans lien. Une source n'est gardée que si l'appli sait ouvrir l'épisode
  /// sans le package : page de l'épisode (cible « episode »), fiche d'un film
  /// (« fiche »), ou page de saison avec l'option à sélectionner
  /// (« saison » + requete_episode). Une page de saison sans requête (ancien
  /// cache du serveur) est écartée : le téléphone la traitera en secours.
  static (List<SourceLecture>, List<SiteSansLien>) depuisServeur(
      Map<String, dynamic> reponse) {
    final sources = <SourceLecture>[];
    final sansLien = <SiteSansLien>[];
    final vus = <String>{};
    final sitesAvecLien = <String>{};
    for (final brut in (reponse['sources'] as List? ?? const [])) {
      final s = (brut as Map).cast<String, dynamic>();
      final site = '${s['site'] ?? s['id_site'] ?? 'Source'}';
      final page = '${s['page'] ?? ''}'.trim();
      final cible = s['cible'] as String?;
      final requete = s['requete_episode'] as String?;
      final utilisable = s['statut'] == 'trouve' &&
          page.isNotEmpty &&
          (cible == 'episode' || cible == 'fiche' || (cible == 'saison' && requete != null));
      if (!utilisable) {
        if (s['statut'] == 'absent' || s['statut'] == 'injoignable') {
          sansLien.add(SiteSansLien(site, s['statut'] as String));
        }
        continue;
      }
      if (!vus.add(page)) continue;
      final langues = [for (final l in (s['langues'] as List? ?? const [])) '$l'];
      sitesAvecLien.add(site);
      sources.add(SourceLecture(
          // « Anime-sama · VF » et « Anime-sama · VOSTFR » : deux tuiles distinctes
          site: langues.isEmpty ? site : '$site · ${langues.join('/')}',
          lien: page,
          requete: cible == 'saison' ? requete : '',
          langues: langues));
    }
    // un site qui a un lien pour une langue n'est pas « absent » (l'autre langue a pu l'être)
    final vusSansLien = <String>{};
    return (
      sources,
      [
        for (final x in sansLien)
          if (!sitesAvecLien.contains(x.site) && vusSansLien.add(x.site)) x
      ]
    );
  }

  /// Index de la source à présélectionner : la dernière utilisée si elle
  /// fait partie des résultats (nom comparé sans casse), sinon la première.
  static int sourceParDefaut(List<SourceLecture> sources, String? derniere) {
    if (derniere == null) return 0;
    final d = derniere.trim().toLowerCase();
    var i = sources.indexWhere((s) => s.site.toLowerCase() == d);
    // « Anime-sama » (historique d'une recherche du téléphone) ↔ « Anime-sama · VF »
    if (i < 0) i = sources.indexWhere((s) => s.site.toLowerCase().split(' · ').first == d.split(' · ').first);
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
