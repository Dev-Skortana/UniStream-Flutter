import 'package:unistream/Gathering_Datas_Videos_From_Web/Data_Json_Into_Object/Register_Data.dart';
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
      GenreManager: this._getGenresFromString(object_data.Liste_Genres),
      PaysManager: this._getPaysFromString(object_data.Liste_Pays),
      RealisateurManager:
          this._getRealisateursFromString(object_data.Liste_Realisateurs),
      VideoManager: Video(
          titre: object_data.Titre,
          description: object_data.Description,
          duree: object_data.Duree,
          date_parution: object_data.Date_Parution,
          lien_affiche: object_data.Lien_Affiche),
      VideoGenreManager: this._getVideoGenresFromString(
          titre_video: object_data.Titre,
          genres_string: object_data.Liste_Genres),
      VideoPaysManager: this._getVideoPaysFromString(
          titre_video: object_data.Titre, pays_string: object_data.Liste_Pays),
      VideoRealisateurManager: this._getVideosRealisateursFromString(
          titre_video: object_data.Titre,
          realisateurss_string: object_data.Liste_Realisateurs),
      VideoFimManager: VideoFilm(
          video: Video(
              titre: object_data.Titre,
              description: object_data.Description,
              duree: object_data.Duree,
              date_parution: object_data.Date_Parution,
              lien_affiche: object_data.Lien_Affiche)),
      FilmManager: Film(
          videoFilm: VideoFilm(
              video: Video(
                  titre: object_data.Titre,
                  description: object_data.Description,
                  duree: object_data.Duree,
                  date_parution: object_data.Date_Parution,
                  lien_affiche: object_data.Lien_Affiche))),
      DramaFilmManager: DramaFilm(
          videoFilm: VideoFilm(
              video: Video(
                  titre: object_data.Titre,
                  description: object_data.Description,
                  duree: object_data.Duree,
                  date_parution: object_data.Date_Parution,
                  lien_affiche: object_data.Lien_Affiche))),
      AnimeFilmManager: AnimeFilm(
          videoFilm: VideoFilm(
              video: Video(
                  titre: object_data.Titre,
                  description: object_data.Description,
                  duree: object_data.Duree,
                  date_parution: object_data.Date_Parution,
                  lien_affiche: object_data.Lien_Affiche)),
          studio: object_data.Studio_Animes),
      VideoSerieManager: VideoSerie(
          video: Video(
              titre: object_data.Titre,
              description: object_data.Description,
              duree: object_data.Duree,
              date_parution: object_data.Date_Parution,
              lien_affiche: object_data.Lien_Affiche)),
      DetailVideoSerieManager: this._getDetailsVideoSeriesFromMap(
          titre_video: object_data.Titre,
          dictionnarysaisonwithepisodethem:
              object_data.DictionnarySaisonWithEpisodeThem),
      SerieManager: Serie(
          videoSerie: VideoSerie(
              video: Video(
                  titre: object_data.Titre,
                  description: object_data.Description,
                  duree: object_data.Duree,
                  date_parution: object_data.Date_Parution,
                  lien_affiche: object_data.Lien_Affiche))),
      DramaSerieManager: DramaSerie(
          videoSerie: VideoSerie(
              video: Video(
                  titre: object_data.Titre,
                  description: object_data.Description,
                  duree: object_data.Duree,
                  date_parution: object_data.Date_Parution,
                  lien_affiche: object_data.Lien_Affiche))),
      AnimeSerieManager: AnimeSerie(
          videoSerie: VideoSerie(
              video: Video(
                  titre: object_data.Titre,
                  description: object_data.Description,
                  duree: object_data.Duree,
                  date_parution: object_data.Date_Parution,
                  lien_affiche: object_data.Lien_Affiche)),
          studio: object_data.Studio_Animes)
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
