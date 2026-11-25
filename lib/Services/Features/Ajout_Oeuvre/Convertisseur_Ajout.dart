import 'package:flutter/material.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:unistream/Models/Ajout_Oeuvre.dart';
import 'package:unistream/Services/Features/Synchronisation/Comparateur_Synchronisation.dart';

/// Réponse de l'API → ce que l'appli sait enregistrer. Logique PURE (ni base ni réseau), testée seule.
///
/// La sortie finale est un RegisterData, l'objet que produit le scraping XPath de l'écran « Enregistrements » :
/// l'ajout depuis l'API passe ainsi par les mêmes dictionnaires (modèle ↔ manager) et les mêmes tables.
class ConvertisseurAjout {
  /// Résultats regroupés par œuvre. [trier] : meilleur score en tête (recherche) ; sinon l'ordre du serveur est
  /// gardé (nouveautés : la plus récente d'abord).
  static List<GroupeOeuvre> regrouper(List<VersionTrouvee> versions, {bool trier = true}) {
    final parOeuvre = <int, List<VersionTrouvee>>{}; // une Map Dart garde l'ordre d'insertion
    for (final v in versions) {
      parOeuvre.putIfAbsent(v.idOeuvre, () => []).add(v);
    }
    final groupes = [
      for (final e in parOeuvre.entries) GroupeOeuvre(e.key, e.value.first.titreOeuvre, e.value.first.famille, e.value)
    ];
    for (final g in groupes) {
      g.versions.sort((a, b) => '${a.site}${a.libelleLangues}'.compareTo('${b.site}${b.libelleLangues}'));
    }
    if (trier) {
      // List.sort n'est pas stable : l'index d'origine départage les ex aequo
      final rang = {for (final (i, g) in groupes.indexed) g.idOeuvre: i};
      groupes.sort((a, b) {
        final c = b.meilleurScore.compareTo(a.meilleurScore);
        return c != 0 ? c : rang[a.idOeuvre]!.compareTo(rang[b.idOeuvre]!);
      });
    }
    return groupes;
  }

  /// Cette version précise est-elle déjà dans la bibliothèque ?
  static bool possedee(VersionTrouvee v, EtatBibliotheque b) => b.cles.contains(v.cle) || b.titres.contains(v.titre);

  /// L'œuvre a-t-elle au moins une version dans la bibliothèque ?
  static bool dansBibliotheque(GroupeOeuvre g, EtatBibliotheque b) =>
      b.oeuvres.contains(g.idOeuvre) || g.versions.any((v) => possedee(v, b));

  static bool _passe(VersionTrouvee v, String famille, FiltresAjout f) {
    final langueOk = f.langues.isEmpty || v.langues.isEmpty || v.langues.any(f.langues.contains);
    final familleOk = f.familles.isEmpty || famille.isEmpty || f.familles.contains(famille);
    return langueOk && familleOk;
  }

  /// (à ajouter, dans ma bibliothèque) après filtrage. Une œuvre sans version restante disparaît.
  static (List<GroupeOeuvre>, List<GroupeOeuvre>) repartir(
      List<GroupeOeuvre> groupes, EtatBibliotheque b, FiltresAjout f) {
    final aAjouter = <GroupeOeuvre>[], presentes = <GroupeOeuvre>[];
    for (final g in groupes) {
      final versions = g.versions.where((v) => _passe(v, g.famille, f)).toList();
      if (versions.isEmpty) continue;
      final filtre = GroupeOeuvre(g.idOeuvre, g.titreOeuvre, g.famille, versions);
      (dansBibliotheque(g, b) ? presentes : aAjouter).add(filtre);
    }
    return (aAjouter, presentes);
  }

  /// (type complet, déduit avec certitude ?) — la famille vient de l'œuvre, la catégorie de la fiche.
  /// Catégorie inconnue : plusieurs saisons ou plusieurs épisodes ⇒ série ; sinon série par défaut, à vérifier.
  static (EnumerationFulltypeVideo, bool) typeComplet(
      {required String famille, required String? categorie, required Map<int, int> episodesParSaison}) {
    bool? film = switch (categorie) { 'Film' => true, 'Serie' => false, _ => null };
    final sur = film != null;
    if (film == null && (episodesParSaison.length > 1 || episodesParSaison.values.any((n) => n > 1))) {
      film = false;
    }
    final prefixe = (film ?? false) ? 'Film' : 'Serie';
    final suffixe = switch (famille) { 'Anime' => 'Anime', 'Drama' => 'Drama', _ => prefixe };
    return (EnumerationFulltypeVideo.values.byName('${prefixe}_$suffixe'), sur || film == false);
  }

  /// Saisons lisibles du serveur → saison : nombre d'épisodes.
  /// Une seule saison ⇒ saison 1 : les sites à une fiche par saison (« Dr. STONE Saison 3 ») sont rangés
  /// ainsi dans l'appli, comme le fait la synchronisation.
  static Map<int, int> episodes(List<dynamic> saisons) {
    final lisibles = <int, int>{};
    for (final s in saisons) {
      final n = (s['numero'] as num?)?.toInt();
      final nb = (s['episodes'] as num?)?.toInt();
      if (n != null && nb != null && nb > 0) lisibles[n] = nb;
    }
    if (lisibles.length == 1) return {1: lisibles.values.first};
    return Map.fromEntries(lisibles.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  /// « Action, Comédie », ["Action", "Comédie"] ou [{valeur: "Action"}, …] (champ « liste » d'un schéma)
  /// → liste propre, sans doublon.
  static List<String> liste(Object? v) {
    String texte(Object? x) => x is Map ? '${x['valeur'] ?? ''}' : '${x ?? ''}';
    final brut = v is List ? v.map(texte) : (v == null ? const <String>[] : texte(v).split(','));
    final vus = <String>{};
    return [
      for (final x in brut.map((x) => x.trim()))
        if (x.isNotEmpty && vus.add(x.toLowerCase())) x
    ];
  }

  /// Rubriques de navigation du site lues avec les genres (JustStream : « Séries », « Films », « Séries VOSTFR ») :
  /// ce ne sont pas des genres.
  static final _rubrique = RegExp(r'^(s[ée]ries?|films?)(\s+(vf|vostfr|vost))?$', caseSensitive: false);
  static List<String> genres(Object? v) => [for (final g in liste(v)) if (!_rubrique.hasMatch(g)) g];

  static int? minutes(Object? v) {
    final m = v is num ? v.toInt() : int.tryParse('${v ?? ''}'.trim());
    return (m == null || m <= 0) ? null : (m > 23 * 60 + 59 ? 23 * 60 + 59 : m);
  }

  static ApercuAjout apercu(VersionTrouvee version, Map<String, dynamic> details, {required bool dejaPresent}) {
    final champs = (details['champs'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    // langue complétée par la lecture de la fiche (le serveur renvoie la fiche à jour)
    final lues = [for (final l in (details['langues'] as List? ?? const [])) '$l'.toLowerCase()];
    if (lues.isNotEmpty) version = version.avecLangues(lues);
    final eps = episodes((details['saisons'] as List?) ?? const []);
    final (type, sur) = typeComplet(
        famille: '${details['famille'] ?? version.famille}',
        categorie: (details['categorie'] as String?) ?? version.categorie,
        episodesParSaison: eps);
    final date = ComparateurSynchronisation.dateDepuisChamps(champs);
    final affiche = '${champs['url_poster'] ?? details['url_poster'] ?? version.urlPoster ?? ''}'.trim();
    return ApercuAjout(
      version: version,
      titre: version.titre,
      typeComplet: type,
      typeDeduit: sur,
      synopsis: '${champs['synopsis'] ?? ''}'.trim(),
      dateParution: date == null ? null : DateTime.parse(date),
      dureeMinutes: minutes(champs['duree']),
      genres: genres(champs['genres']),
      pays: liste(champs['pays']),
      realisateurs: liste(champs['realisateurs']),
      studio: liste(champs['studios']).join(', '),
      episodesParSaison: eps,
      urlPoster: affiche.startsWith('http') ? affiche : null,
      avertissement: details['avertissement'] as String?,
      dejaPresent: dejaPresent,
    );
  }

  /// Aperçu validé → RegisterData (le même objet que le scraping XPath).
  /// [lienAffiche] : chemin du fichier téléchargé sur l'appareil (Image.file), ou le fichier « introuvable ».
  static RegisterData versRegisterData(ApercuAjout a, {required String lienAffiche}) {
    final m = a.dureeMinutes ?? 0;
    return RegisterData(
      RegisterMetaData.getEmptyRegisterMetaData(),
      a.titre,
      a.synopsis,
      TimeOfDay(hour: m ~/ 60, minute: m % 60),
      a.dateParution,
      lienAffiche,
      a.genres,
      a.pays,
      a.realisateurs,
      a.estSerie ? {for (final e in a.episodesParSaison.entries) e.key: [for (var i = 1; i <= e.value; i++) i]} : {},
      a.studio,
      a.typeComplet,
    );
  }
}
