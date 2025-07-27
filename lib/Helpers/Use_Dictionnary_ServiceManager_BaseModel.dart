import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';
import 'package:unistream/Services/Databases/Genre_Manager.dart';
import 'package:unistream/Services/Databases/Pays_Manager.dart';
import 'package:unistream/Services/Databases/Realisateur_Manager.dart';
import 'package:unistream/Services/Databases/Video_Genre_Manager.dart';
import 'package:unistream/Services/Databases/Video_Pays_Manager.dart';
import 'package:unistream/Services/Databases/Video_Realisateur_Manager.dart';
import 'package:unistream/Services/Databases/Video_Manager.dart';
import 'package:unistream/Services/Databases/Video_Serie_Manager.dart';
import 'package:unistream/Services/Databases/Video_Fim_Manager.dart';
import 'package:unistream/Services/Databases/Detail_Video_Serie_Manager.dart';
import 'package:unistream/Services/Databases/Film_Manager.dart';
import 'package:unistream/Services/Databases/Drama_Film_Manager.dart';
import 'package:unistream/Services/Databases/Anime_Film_Manager.dart';
import 'package:unistream/Services/Databases/Serie_Manager.dart';
import 'package:unistream/Services/Databases/Drama_Serie_Manager.dart';
import 'package:unistream/Services/Databases/Anime_Serie_Manager.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Genre.dart';
import 'package:unistream/Models/Pays.dart';
import 'package:unistream/Models/Realisateur.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Genre.dart';
import 'package:unistream/Models/Video_Pays.dart';
import 'package:unistream/Models/Video_Realisateur.dart';
import 'package:unistream/Models/Video_Film.dart';
import 'package:unistream/Models/Film.dart';
import 'package:unistream/Models/Drama_Film.dart';
import 'package:unistream/Models/Anime_Film.dart';
import 'package:unistream/Models/Video_Serie.dart';
import 'package:unistream/Models/Detail_Video_Serie.dart';
import 'package:unistream/Models/Serie.dart';
import 'package:unistream/Models/Drama_Serie.dart';
import 'package:unistream/Models/Anime_Serie.dart';

class UseDictionnaryServicemanagerBasemodel {
  late Map<Type, dynamic> __DictionnaryServiceManagerBaseModel;

  Map<Type, dynamic> get DictionnaryServiceManagerBaseModel =>
      this.__DictionnaryServiceManagerBaseModel;

  UseDictionnaryServicemanagerBasemodel(RegisterData object_data) {
    this.__DictionnaryServiceManagerBaseModel = {
      GenreManager: this._getGenresFromString(object_data.liste_Genres),
      PaysManager: this._getPaysFromString(object_data.liste_Pays),
      RealisateurManager:
          this._getRealisateursFromString(object_data.liste_Realisateurs),
      VideoManager: Video(
          titre: object_data.titre,
          description: object_data.description,
          duree: object_data.duree,
          date_parution: object_data.date_Parution,
          lien_affiche: object_data.lien_Affiche),
      VideoGenreManager: this._getVideoGenresFromString(
          titre_video: object_data.titre,
          genres_string: object_data.liste_Genres),
      VideoPaysManager: this._getVideoPaysFromString(
          titre_video: object_data.titre, pays_string: object_data.liste_Pays),
      VideoRealisateurManager: this._getVideosRealisateursFromString(
          titre_video: object_data.titre,
          realisateurss_string: object_data.liste_Realisateurs),
      VideoFimManager: VideoFilm(
          video: Video(
              titre: object_data.titre,
              description: object_data.description,
              duree: object_data.duree,
              date_parution: object_data.date_Parution,
              lien_affiche: object_data.lien_Affiche)),
      FilmManager: Film(
          videoFilm: VideoFilm(
              video: Video(
                  titre: object_data.titre,
                  description: object_data.description,
                  duree: object_data.duree,
                  date_parution: object_data.date_Parution,
                  lien_affiche: object_data.lien_Affiche))),
      DramaFilmManager: DramaFilm(
          videoFilm: VideoFilm(
              video: Video(
                  titre: object_data.titre,
                  description: object_data.description,
                  duree: object_data.duree,
                  date_parution: object_data.date_Parution,
                  lien_affiche: object_data.lien_Affiche))),
      AnimeFilmManager: AnimeFilm(
          videoFilm: VideoFilm(
              video: Video(
                  titre: object_data.titre,
                  description: object_data.description,
                  duree: object_data.duree,
                  date_parution: object_data.date_Parution,
                  lien_affiche: object_data.lien_Affiche)),
          studio: object_data.studio_Animes),
      VideoSerieManager: VideoSerie(
          video: Video(
              titre: object_data.titre,
              description: object_data.description,
              duree: object_data.duree,
              date_parution: object_data.date_Parution,
              lien_affiche: object_data.lien_Affiche)),
      DetailVideoSerieManager: this._getDetailsVideoSeriesFromMap(
          titre_video: object_data.titre,
          dictionnarysaisonwithepisodethem:
              object_data.dictionnarySaisonWithEpisodeThem),
      SerieManager: Serie(
          videoSerie: VideoSerie(
              video: Video(
                  titre: object_data.titre,
                  description: object_data.description,
                  duree: object_data.duree,
                  date_parution: object_data.date_Parution,
                  lien_affiche: object_data.lien_Affiche))),
      DramaSerieManager: DramaSerie(
          videoSerie: VideoSerie(
              video: Video(
                  titre: object_data.titre,
                  description: object_data.description,
                  duree: object_data.duree,
                  date_parution: object_data.date_Parution,
                  lien_affiche: object_data.lien_Affiche))),
      AnimeSerieManager: AnimeSerie(
          videoSerie: VideoSerie(
              video: Video(
                  titre: object_data.titre,
                  description: object_data.description,
                  duree: object_data.duree,
                  date_parution: object_data.date_Parution,
                  lien_affiche: object_data.lien_Affiche)),
          studio: object_data.studio_Animes)
    };
  }

  List<Genre> _getGenresFromString(Iterable genres_string) =>
      [for (var item in genres_string) Genre(nom: item)];

  List<Pays> _getPaysFromString(Iterable pays_string) =>
      [for (var item in pays_string) Pays(nom: item)];

  List<Realisateur> _getRealisateursFromString(Iterable realisateurs_string) =>
      [for (var item in realisateurs_string) Realisateur(nom: item)];

  List<VideoGenre> _getVideoGenresFromString(
          {required String? titre_video, required Iterable? genres_string}) =>
      [
        for (var item in genres_string!)
          VideoGenre(titre: titre_video!, nom: item)
      ];
  List<VideoPays> _getVideoPaysFromString(
          {required String? titre_video, required Iterable? pays_string}) =>
      [
        for (var item in pays_string!) VideoPays(titre: titre_video!, nom: item)
      ];

  List<VideoRealisateur> _getVideosRealisateursFromString(
          {required String? titre_video,
          required Iterable? realisateurss_string}) =>
      [
        for (var item in realisateurss_string!)
          VideoRealisateur(titre: titre_video!, nom: item)
      ];

  List<DetailVideoSerie> _getDetailsVideoSeriesFromMap(
      {required String? titre_video,
      required Map<int, List<int>>? dictionnarysaisonwithepisodethem}) {
    List<DetailVideoSerie> details = [];
    dictionnarysaisonwithepisodethem!.forEach((key, values) {
      for (int episode in values) {
        details.add(DetailVideoSerie(
            titreVideoSerie: titre_video!, saison: key, episode: episode));
      }
    });
    return details;
  }
}
