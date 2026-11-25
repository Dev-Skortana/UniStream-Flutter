import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';

/// Une fiche de l'index (une « version » d'une œuvre : un site, une langue), telle que /v1/rechercher la renvoie.
class VersionTrouvee {
  final String cle; // « id_site|chemin »
  final String idSite;
  final String site;
  final String urlFiche;
  final String titre; // titre affiché par le site (« Lazarus (VF) ») = titre de l'appli
  final String titreOeuvre;
  final int idOeuvre;
  final String famille; // Anime | Drama | '' (inconnue)
  final String? categorie; // Film | Serie | Autre | null
  final List<String> langues; // [vf], [vostfr]…
  final String? urlPoster;
  final int score;
  final String? correspondance; // mot | debut | partielle (null : nouveautés, sans recherche)

  VersionTrouvee({
    required this.cle,
    required this.idSite,
    required this.site,
    required this.urlFiche,
    required this.titre,
    required this.titreOeuvre,
    required this.idOeuvre,
    required this.famille,
    required this.categorie,
    required this.langues,
    required this.urlPoster,
    required this.score,
    this.correspondance,
  });

  factory VersionTrouvee.depuisJson(Map<String, dynamic> j) => VersionTrouvee(
        cle: '${j['cle']}',
        idSite: '${j['id_site']}',
        site: '${j['site'] ?? j['id_site']}',
        urlFiche: '${j['url_fiche']}',
        titre: '${j['titre'] ?? ''}'.trim(),
        titreOeuvre: '${j['titre_oeuvre'] ?? j['titre'] ?? ''}'.trim(),
        idOeuvre: (j['oeuvre_id'] as num).toInt(),
        famille: '${j['famille'] ?? ''}',
        categorie: j['categorie'] as String?,
        // le serveur écrit « VF », « VOSTFR » : minuscules ici, pour comparer sans surprise avec les filtres
        langues: [for (final l in (j['langues'] as List? ?? const [])) '$l'.toLowerCase()],
        urlPoster: j['url_poster'] as String?,
        score: (j['score'] as num?)?.toInt() ?? 0,
        correspondance: j['correspondance'] as String?,
      );

  VersionTrouvee avecLangues(List<String> l) => VersionTrouvee(
        cle: cle, idSite: idSite, site: site, urlFiche: urlFiche, titre: titre, titreOeuvre: titreOeuvre,
        idOeuvre: idOeuvre, famille: famille, categorie: categorie, langues: l, urlPoster: urlPoster, score: score,
        correspondance: correspondance);

  /// « VF », « VOSTFR », « VF · VOSTFR » ou « langue ? »
  String get libelleLangues => langues.isEmpty ? 'langue ?' : langues.map((l) => l.toUpperCase()).join(' · ');
}

/// Les versions d'une même œuvre, regroupées pour l'affichage (meilleur score en tête).
class GroupeOeuvre {
  final int idOeuvre;
  final String titreOeuvre;
  final String famille;
  final List<VersionTrouvee> versions;
  GroupeOeuvre(this.idOeuvre, this.titreOeuvre, this.famille, this.versions);
  int get meilleurScore => versions.map((v) => v.score).fold(0, (a, b) => a > b ? a : b);

  /// Trouvée seulement en milieu ou fin de mot (ou mots manquants) : affichée après les autres.
  bool get partielle => versions.every((v) => v.correspondance == 'partielle');
}

/// Ce qui sera ajouté à la bibliothèque, montré AVANT l'écriture.
class ApercuAjout {
  final VersionTrouvee version;
  final String titre; // titre sous lequel l'œuvre entre dans l'appli (modifiable)
  final EnumerationFulltypeVideo typeComplet;
  final bool typeDeduit; // false : catégorie inconnue du serveur, à vérifier par l'utilisateur
  final String synopsis;
  final DateTime? dateParution;
  final int? dureeMinutes;
  final List<String> genres, pays, realisateurs;
  final String studio;
  final Map<int, int> episodesParSaison; // saison → nombre d'épisodes (numérotés 1..n)
  final String? urlPoster;
  final String? avertissement; // relecture impossible, saisons illisibles…
  final bool dejaPresent; // le titre existe déjà dans la bibliothèque

  ApercuAjout({
    required this.version,
    required this.titre,
    required this.typeComplet,
    required this.typeDeduit,
    required this.synopsis,
    required this.dateParution,
    required this.dureeMinutes,
    required this.genres,
    required this.pays,
    required this.realisateurs,
    required this.studio,
    required this.episodesParSaison,
    required this.urlPoster,
    required this.avertissement,
    required this.dejaPresent,
  });

  bool get estSerie => typeComplet.name.startsWith('Serie_');
  int get nbEpisodes => episodesParSaison.values.fold(0, (a, b) => a + b);

  ApercuAjout copier({String? titre, EnumerationFulltypeVideo? typeComplet, bool? dejaPresent}) => ApercuAjout(
        version: version,
        titre: titre ?? this.titre,
        typeComplet: typeComplet ?? this.typeComplet,
        typeDeduit: typeComplet != null ? true : typeDeduit,
        synopsis: synopsis,
        dateParution: dateParution,
        dureeMinutes: dureeMinutes,
        genres: genres,
        pays: pays,
        realisateurs: realisateurs,
        studio: studio,
        episodesParSaison: episodesParSaison,
        urlPoster: urlPoster,
        avertissement: avertissement,
        dejaPresent: dejaPresent ?? this.dejaPresent,
      );
}

/// Ce que la bibliothèque contient déjà, pour classer les résultats (chargé une fois, rafraîchi après un ajout).
class EtatBibliotheque {
  final Set<int> oeuvres; // Oeuvres_Liens.Id_Oeuvre
  final Set<String> cles; // Oeuvres_Liens.Cle_Fiche : la version suivie
  final Set<String> titres; // Videos.Titre : secours pour les titres pas encore reliés
  const EtatBibliotheque({this.oeuvres = const {}, this.cles = const {}, this.titres = const {}});
}

/// Filtres de l'écran d'ajout. Ensemble vide = pas de filtre.
/// Une valeur INCONNUE (langue ou famille non renseignée) n'est jamais exclue : un filtre ne cache pas ce qu'il
/// ne sait pas classer.
class FiltresAjout {
  final Set<String> langues; // vf, vostfr
  final Set<String> familles; // Anime, Drama
  const FiltresAjout({this.langues = const {}, this.familles = const {}});

  bool get actifs => langues.isNotEmpty || familles.isNotEmpty;

  FiltresAjout basculerLangue(String l) =>
      FiltresAjout(langues: langues.contains(l) ? ({...langues}..remove(l)) : {...langues, l}, familles: familles);
  FiltresAjout basculerFamille(String f) =>
      FiltresAjout(langues: langues, familles: familles.contains(f) ? ({...familles}..remove(f)) : {...familles, f});
}
