import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
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

class UseDictionnaryFulltypevideoListservicemanager {
  late Map<String, Map<String, dynamic>>
      __DictionnaryFullTypeVideoListServiceManager;

  Map<String, Map<String, dynamic>>
      get DictionnaryFullTypeVideoListServiceManager =>
          this.__DictionnaryFullTypeVideoListServiceManager;

  UseDictionnaryFulltypevideoListservicemanager() {
    this.__DictionnaryFullTypeVideoListServiceManager = {
      EnumerationFulltypeVideo.Film_Film.name: {
        "Types": [
          GenreManager,
          PaysManager,
          RealisateurManager,
          VideoManager,
          VideoGenreManager,
          VideoPaysManager,
          VideoRealisateurManager,
          VideoFimManager,
          FilmManager
        ],
        "Instances": [
          GenreManager.new,
          PaysManager.new,
          RealisateurManager.new,
          VideoManager.new,
          VideoGenreManager.new,
          VideoPaysManager.new,
          VideoRealisateurManager.new,
          VideoFimManager.new,
          FilmManager.new
        ]
      },
      EnumerationFulltypeVideo.Film_Anime.name: {
        "Types": [
          GenreManager,
          PaysManager,
          RealisateurManager,
          VideoManager,
          VideoGenreManager,
          VideoPaysManager,
          VideoRealisateurManager,
          VideoFimManager,
          AnimeFilmManager
        ],
        "Instances": [
          GenreManager.new,
          PaysManager.new,
          RealisateurManager.new,
          VideoManager.new,
          VideoGenreManager.new,
          VideoPaysManager.new,
          VideoRealisateurManager.new,
          VideoFimManager.new,
          AnimeFilmManager.new
        ]
      },
      EnumerationFulltypeVideo.Film_Drama.name: {
        "Types": [
          GenreManager,
          PaysManager,
          RealisateurManager,
          VideoManager,
          VideoGenreManager,
          VideoPaysManager,
          VideoRealisateurManager,
          VideoFimManager,
          DramaFilmManager
        ],
        "Instances": [
          GenreManager.new,
          PaysManager.new,
          RealisateurManager.new,
          VideoManager.new,
          VideoGenreManager.new,
          VideoPaysManager.new,
          VideoRealisateurManager.new,
          VideoFimManager.new,
          DramaFilmManager.new
        ]
      },
      EnumerationFulltypeVideo.Serie_Serie.name: {
        "Types": [
          GenreManager,
          PaysManager,
          RealisateurManager,
          VideoManager,
          VideoGenreManager,
          VideoPaysManager,
          VideoRealisateurManager,
          VideoSerieManager,
          DetailVideoSerieManager,
          SerieManager
        ],
        "Instances": [
          GenreManager.new,
          PaysManager.new,
          RealisateurManager.new,
          VideoManager.new,
          VideoGenreManager.new,
          VideoPaysManager.new,
          VideoRealisateurManager.new,
          VideoSerieManager.new,
          DetailVideoSerieManager.new,
          SerieManager.new
        ]
      },
      EnumerationFulltypeVideo.Serie_Anime.name: {
        "Types": [
          GenreManager,
          PaysManager,
          RealisateurManager,
          VideoManager,
          VideoGenreManager,
          VideoPaysManager,
          VideoRealisateurManager,
          VideoSerieManager,
          DetailVideoSerieManager,
          AnimeSerieManager
        ],
        "Instances": [
          GenreManager.new,
          PaysManager.new,
          RealisateurManager.new,
          VideoManager.new,
          VideoGenreManager.new,
          VideoPaysManager.new,
          VideoRealisateurManager.new,
          VideoSerieManager.new,
          DetailVideoSerieManager.new,
          AnimeSerieManager.new
        ]
      },
      EnumerationFulltypeVideo.Serie_Drama.name: {
        "Types": [
          GenreManager,
          PaysManager,
          RealisateurManager,
          VideoManager,
          VideoGenreManager,
          VideoPaysManager,
          VideoRealisateurManager,
          VideoSerieManager,
          DetailVideoSerieManager,
          DramaSerieManager
        ],
        "Instances": [
          GenreManager.new,
          PaysManager.new,
          RealisateurManager.new,
          VideoManager.new,
          VideoGenreManager.new,
          VideoPaysManager.new,
          VideoRealisateurManager.new,
          VideoSerieManager.new,
          DetailVideoSerieManager.new,
          DramaSerieManager.new
        ]
      }
    };
  }
}
