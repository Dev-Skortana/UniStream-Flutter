import 'package:flutter/foundation.dart';
import 'package:unistream/Models/Anime_Film.dart';
import 'package:unistream/Models/Anime_Serie.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Detail/Infos_Detail.dart';
import 'package:unistream/Services/Features/Detail/Lecture_Detail.dart';
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
      if (lues.saisons.isNotEmpty) choisirSaison(lues.saisons.first);
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

  /// Catégorie attendue par la boîte de dialogue des liens.
  String get categorieLecture => estSerie ? "Video_Serie" : "Video_Film";

  void dispose() {
    chargement.dispose();
    erreur.dispose();
    infos.dispose();
    saison.dispose();
    episode.dispose();
    rechercheEnCours.dispose();
  }
}
