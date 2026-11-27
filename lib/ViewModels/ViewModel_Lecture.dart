import 'package:flutter/foundation.dart';
import 'package:unistream/Services/Databases/Historique_Manager.dart';
import 'package:unistream/Services/Databases/Oeuvre_Lien_Manager.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Historique/Suivi_Visionnage.dart';
import 'package:unistream/Services/Features/Lecture/Navigation_Lecture.dart';
import 'package:unistream/Services/Features/Lecture/Preparation_Lecture.dart';
import 'package:unistream/Services/Features/Link_Watch_Video/Result_Link_Watch_Of_Video.dart';
import 'package:unistream/Services/Features/Synchronisation/Api_Unistream.dart';

enum EtatRecherche { enCours, resultats, aucun }

enum OngletLecture { sources, episodes }

/// État de la feuille de lecture : épisode choisi, recherche des liens,
/// source choisie, historique (vus, dernière source).
class ViewmodelLecture {
  final OeuvreBibliotheque oeuvre;

  /// Saison → épisodes (vide pour un film).
  final Map<int, List<int>> episodesParSaison;

  /// (saison, épisode) choisi ; null pour un film.
  final ValueNotifier<(int, int)?> episode;
  final ValueNotifier<EtatRecherche> etat = ValueNotifier(EtatRecherche.enCours);
  final ValueNotifier<String?> erreur = ValueNotifier(null);
  final ValueNotifier<List<SourceLecture>> sources = ValueNotifier(const []);
  final ValueNotifier<int> choisie = ValueNotifier(0);
  final ValueNotifier<OngletLecture> onglet = ValueNotifier(OngletLecture.sources);
  final ValueNotifier<SuiviOeuvre?> suivi = ValueNotifier(null);

  /// Qui a trouvé les sources (serveur ou téléphone), et les sites du
  /// serveur sans lien (« VoirDrama injoignable »).
  final ValueNotifier<ProvenanceSources?> provenance = ValueNotifier(null);
  final ValueNotifier<List<SiteSansLien>> sansLien = ValueNotifier(const []);

  /// Le serveur a répondu à /sante lors de cette ouverture : null = pas encore
  /// essayé. Hors de la maison, on ne le réinterroge pas à chaque épisode.
  bool? _serveurJoignable;

  /// Délai pour savoir si le serveur est là : court, pour que le secours du
  /// téléphone démarre vite hors du réseau local.
  static const delaiSante = Duration(seconds: 3);

  /// Site utilisé la dernière fois pour cette œuvre (historique).
  String? derniereSource;

  /// Numéro de la recherche en cours : une réponse qui arrive après un
  /// changement d'épisode ou une annulation porte un ancien numéro et
  /// est ignorée (le package ne sait pas interrompre une collecte).
  int _generation = 0;

  /// La feuille a été fermée : plus aucune écriture dans les notifiers
  /// (une réponse tardive lèverait « used after being disposed »).
  bool _ferme = false;

  ViewmodelLecture(
      {required this.oeuvre,
      required this.episodesParSaison,
      (int, int)? episodeInitial})
      : episode = ValueNotifier(episodeInitial);

  bool get estSerie => oeuvre.format == FormatOeuvre.serie;

  int get nombreEpisodes =>
      episodesParSaison.values.fold(0, (n, eps) => n + eps.length);

  (int, int)? get precedent => _voisin(-1);
  (int, int)? get suivant => _voisin(1);

  (int, int)? _voisin(int sens) {
    final e = episode.value;
    return e == null ? null : NavigationLecture.voisin(episodesParSaison, e, sens);
  }

  /// Épisodes avant celui choisi (pour « vus jusqu'à … »).
  List<(int, int)> get episodesAvant {
    final e = episode.value;
    return e == null ? const [] : NavigationLecture.avant(episodesParSaison, e);
  }

  bool estVu((int, int) ep) => suivi.value?.vus.contains(ep) ?? false;

  bool estDerniereSource(SourceLecture s) =>
      derniereSource != null &&
      s.site.toLowerCase() == derniereSource!.trim().toLowerCase();

  Future<void> demarrer() async {
    try {
      derniereSource = await HistoriqueManager().derniereSource(oeuvre.titre);
    } catch (e) {
      debugPrint("[Lecture] dernière source illisible : $e");
    }
    await _lireSuivi();
    if (!_ferme) await chercher();
  }

  /// Le serveur d'abord (œuvre reliée par la Synchronisation, serveur
  /// joignable), sinon la recherche du téléphone. Rien ne casse sans le Pi.
  Future<void> chercher() async {
    final generation = ++_generation;
    etat.value = EtatRecherche.enCours;
    erreur.value = null;
    sources.value = const [];
    sansLien.value = const [];
    provenance.value = null;
    final e = episode.value;
    if (await _chercherSurLeServeur(generation, e)) return;
    if (generation != _generation) return;
    try {
      final resultats = await ResultLinkWatchOfVideo().getManyResultLinkWatchOfVideo({
        "titre_video": oeuvre.titre,
        if (estSerie && e != null) "saison": '${e.$1}',
        if (estSerie && e != null) "episode": '${e.$2}',
      });
      if (generation != _generation) return;
      final trouvees = NavigationLecture.sources(resultats);
      sources.value = trouvees;
      provenance.value = ProvenanceSources.telephone;
      choisie.value = NavigationLecture.sourceParDefaut(trouvees, derniereSource);
      etat.value = trouvees.isEmpty ? EtatRecherche.aucun : EtatRecherche.resultats;
    } catch (err) {
      if (generation != _generation) return;
      debugPrint("[Lecture] recherche des liens impossible : $err");
      erreur.value = "La recherche a échoué : $err";
      etat.value = EtatRecherche.aucun;
    }
  }

  /// true si le serveur a fourni au moins une source (la recherche s'arrête là).
  Future<bool> _chercherSurLeServeur(int generation, (int, int)? e) async {
    if (!ApiUnistreamConfig.configuree || _serveurJoignable == false) return false;
    try {
      final lien = await OeuvreLienManager().lienServeur(oeuvre.titre);
      if (lien == null) return false; // titre non relié : secours du téléphone
      final api = ApiUnistream();
      _serveurJoignable ??= await api.sante(delai: delaiSante);
      if (_serveurJoignable != true || generation != _generation) return false;
      final reponse = await api.liens(lien.idOeuvre,
          saison: estSerie && e != null ? e.$1 : 0,
          episode: estSerie && e != null ? e.$2 : 0,
          cleReference: lien.cleFiche);
      if (generation != _generation) return true; // réponse périmée : ignorée
      final (trouvees, sites) = NavigationLecture.depuisServeur(reponse);
      if (trouvees.isEmpty) {
        // L'index ne connaît pas l'épisode sur ses sites : le téléphone essaie
        // les siens (ils ne sont pas tous indexés).
        debugPrint("[Lecture] serveur : aucune source (${sites.map((s) => s.libelle).join(', ')})");
        return false;
      }
      sources.value = trouvees;
      sansLien.value = sites;
      provenance.value = ProvenanceSources.serveur;
      choisie.value = NavigationLecture.sourceParDefaut(trouvees, derniereSource);
      etat.value = EtatRecherche.resultats;
      return true;
    } on ApiUnistreamException catch (err) {
      debugPrint("[Lecture] serveur indisponible, recherche sur le téléphone : $err");
      return false;
    } catch (err) {
      debugPrint("[Lecture] réponse du serveur inexploitable : $err");
      return false;
    }
  }

  /// Ignore la recherche en cours (la feuille se ferme).
  void annuler() => _generation++;

  void choisirSource(int index) => choisie.value = index;

  void choisirOnglet(OngletLecture o) => onglet.value = o;

  /// Change d'épisode, revient sur les sources et relance la recherche.
  void choisirEpisode((int, int) nouvel) {
    if (nouvel == episode.value && etat.value != EtatRecherche.aucun) {
      onglet.value = OngletLecture.sources;
      return;
    }
    episode.value = nouvel;
    onglet.value = OngletLecture.sources;
    chercher();
  }

  /// Prépare la lecture sur la source [index] et l'enregistre dans
  /// l'historique avec son site. Renvoie le lien et la requête d'épisode
  /// attendus par l'écran de lecture.
  Future<(String lien, String requete)> preparer(int index) async {
    final source = sources.value[index];
    final e = episode.value;
    // Source du serveur : la requête est fournie (aucun appel au package,
    // donc aucune dépendance au domaine du site). Sinon : comme avant.
    final requete = source.requete ??
        await PreparationLecture.requeteEpisode(
            lien: source.lien, estSerie: estSerie, episode: e?.$2 ?? 0);
    try {
      await HistoriqueManager().enregistrer(
        titre: oeuvre.titre,
        saison: e?.$1 ?? 0,
        episode: e?.$2 ?? 0,
        episodesConnus: nombreEpisodes,
        site: source.site,
      );
      derniereSource = source.site;
      await _lireSuivi();
    } catch (err) {
      // L'historique ne doit jamais empêcher de regarder.
      debugPrint("[Lecture] historique non enregistré : $err");
    }
    return (source.lien, requete);
  }

  /// Appui long sur un épisode : vu ↔ non vu.
  Future<void> basculerVu((int, int) ep) async {
    try {
      if (estVu(ep)) {
        await HistoriqueManager()
            .retirer(titre: oeuvre.titre, saison: ep.$1, episode: ep.$2);
      } else {
        await HistoriqueManager().marquerVus(
            titre: oeuvre.titre, episodes: [ep], episodesConnus: nombreEpisodes);
      }
      await _lireSuivi();
    } catch (err) {
      debugPrint("[Lecture] marquage impossible : $err");
    }
  }

  /// Marque vus tous les épisodes avant celui choisi.
  Future<void> marquerVusJusquIci() async {
    try {
      await HistoriqueManager().marquerVus(
          titre: oeuvre.titre, episodes: episodesAvant, episodesConnus: nombreEpisodes);
      await _lireSuivi();
    } catch (err) {
      debugPrint("[Lecture] marquage impossible : $err");
    }
  }

  Future<void> _lireSuivi() async {
    try {
      final entrees = await HistoriqueManager().lire(titre: oeuvre.titre);
      if (_ferme) return;
      suivi.value = SuiviVisionnage.calculer(
          entrees, {oeuvre.titre: episodesParSaison})[oeuvre.titre];
    } catch (err) {
      debugPrint("[Lecture] historique illisible : $err");
    }
  }

  void dispose() {
    _ferme = true;
    _generation++;
    episode.dispose();
    etat.dispose();
    erreur.dispose();
    sources.dispose();
    choisie.dispose();
    onglet.dispose();
    suivi.dispose();
    provenance.dispose();
    sansLien.dispose();
  }
}
