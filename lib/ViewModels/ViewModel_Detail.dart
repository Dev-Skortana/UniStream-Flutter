import 'package:flutter/foundation.dart';
import 'package:unistream/Models/Anime_Film.dart';
import 'package:unistream/Models/Anime_Serie.dart';
import 'package:unistream/Services/Databases/Historique_Manager.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Detail/Infos_Detail.dart';
import 'package:unistream/Services/Features/Detail/Lecture_Detail.dart';
import 'package:unistream/Services/Features/Historique/Suivi_Visionnage.dart';
import 'package:unistream/Services/Features/Link_Watch_Video/Result_Link_Watch_Of_Video.dart';

/// État de l'écran Détail d'UNE œuvre : métadonnées, saison / épisode choisis,
/// recherche des liens de lecture. Même modèle que les ViewModels récents
/// (ValueNotifier + méthodes), aucune dépendance aux widgets.
class ViewmodelDetail {
  final OeuvreBibliotheque oeuvre;

  final ValueNotifier<bool> chargement = ValueNotifier(true);
  final ValueNotifier<String?> erreur = ValueNotifier(null);
  final ValueNotifier<InfosDetail> infos = ValueNotifier(const InfosDetail());
  final ValueNotifier<int?> saison = ValueNotifier(null);
  final ValueNotifier<int?> episode = ValueNotifier(null);
  final ValueNotifier<bool> rechercheEnCours = ValueNotifier(false);

  /// Où en est l'utilisateur sur cette œuvre (null : jamais regardée).
  final ValueNotifier<SuiviOeuvre?> suivi = ValueNotifier(null);

  ViewmodelDetail(this.oeuvre);

  bool get estSerie => oeuvre.format == FormatOeuvre.serie;

  /// Studio : seuls les modèles d'anime en ont un.
  String? get studio {
    final video = oeuvre.video;
    final s = video is AnimeSerie
        ? video.studio
        : video is AnimeFilm
            ? video.studio
            : '';
    return s.trim().isEmpty ? null : s.trim();
  }

  /// La lecture est possible : un film, ou une série dont on connaît l'épisode.
  bool get peutRegarder =>
      !estSerie || (saison.value != null && episode.value != null);

  Future<void> charger() async {
    chargement.value = true;
    erreur.value = null;
    try {
      final lues = await LectureDetail.lire(oeuvre.titre, estSerie: estSerie);
      infos.value = lues;
      await _lireSuivi();
      // Présélection : l'épisode qui suit le dernier regardé, sinon le premier.
      final prochain = suivi.value?.prochain;
      if (prochain != null) {
        saison.value = prochain.$1;
        episode.value = prochain.$2;
      } else if (lues.saisons.isNotEmpty) {
        choisirSaison(lues.saisons.first);
      }
    } catch (e) {
      debugPrint("[Détail] lecture de « ${oeuvre.titre} » impossible : $e");
      erreur.value = "Les informations de cette œuvre n'ont pas pu être lues.";
    } finally {
      chargement.value = false;
    }
  }

  /// Change de saison et présélectionne son premier épisode
  /// (l'ancienne fiche laissait 0, ce qui lançait une recherche invalide).
  void choisirSaison(int nouvelleSaison) {
    saison.value = nouvelleSaison;
    final eps = infos.value.episodesDe(nouvelleSaison);
    episode.value = eps.isEmpty ? null : eps.first;
  }

  void choisirEpisode(int nouvelEpisode) => episode.value = nouvelEpisode;

  /// Cherche les pages de lecture sur les sites. Renvoie null si une
  /// recherche est déjà en cours (double appui).
  Future<List<Map<String, String>>?> chercherLiens() async {
    if (rechercheEnCours.value || !peutRegarder) return null;
    rechercheEnCours.value = true;
    try {
      return await ResultLinkWatchOfVideo().getManyResultLinkWatchOfVideo({
        "titre_video": oeuvre.titre,
        if (estSerie) "saison": saison.value.toString(),
        if (estSerie) "episode": episode.value.toString(),
      });
    } finally {
      rechercheEnCours.value = false;
    }
  }

  /// L'épisode choisi est celui qui suit le dernier regardé.
  bool get estUneReprise {
    final p = suivi.value?.prochain;
    return p != null && p.$1 == saison.value && p.$2 == episode.value;
  }

  bool estVu(int s, int e) => suivi.value?.vus.contains((s, e)) ?? false;

  /// À appeler quand l'utilisateur lance la vidéo : met à jour l'historique.
  /// Une erreur d'écriture est ignorée (l'historique ne doit pas bloquer
  /// la lecture).
  Future<void> enregistrerLecture() async {
    try {
      await HistoriqueManager().enregistrer(
        titre: oeuvre.titre,
        saison: estSerie ? (saison.value ?? 0) : 0,
        episode: estSerie ? (episode.value ?? 0) : 0,
        episodesConnus: infos.value.nombreEpisodes,
      );
      await _lireSuivi();
    } catch (e) {
      debugPrint("[Détail] historique non enregistré : $e");
    }
  }

  Future<void> _lireSuivi() async {
    try {
      final entrees = await HistoriqueManager().lire(titre: oeuvre.titre);
      suivi.value = SuiviVisionnage.calculer(
          entrees, {oeuvre.titre: infos.value.episodesParSaison})[oeuvre.titre];
    } catch (e) {
      debugPrint("[Détail] historique illisible : $e");
      suivi.value = null;
    }
  }

  /// Catégorie attendue par la boîte de dialogue des liens.
  String get categorieLecture => estSerie ? "Video_Serie" : "Video_Film";

  void dispose() {
    chargement.dispose();
    erreur.dispose();
    infos.dispose();
    saison.dispose();
    episode.dispose();
    rechercheEnCours.dispose();
    suivi.dispose();
  }
}
