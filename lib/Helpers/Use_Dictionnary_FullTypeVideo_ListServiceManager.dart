import 'package:unistream/Gathering_Datas_Videos_From_Web/Helpers/Enumerations/Enumeration_FullType_Video.dart';
import 'package:unistream/Services/Databases/Genre_Manager.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';
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
  late Map<EnumerationFulltypeVideo, List<Type>>
      __DictionnaryFullTypeVideoListServiceManager;

  Map<EnumerationFulltypeVideo, List<Type>>
      get DictionnaryFullTypeVideoListServiceManager =>
          this.__DictionnaryFullTypeVideoListServiceManager;

  UseDictionnaryFulltypevideoListservicemanager() {
    this.__DictionnaryFullTypeVideoListServiceManager = {
      EnumerationFulltypeVideo.Film_Film: [
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
      EnumerationFulltypeVideo.Film_Anime: [
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
      EnumerationFulltypeVideo.Film_Drama: [
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
      EnumerationFulltypeVideo.Serie_Serie: [
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
      EnumerationFulltypeVideo.Serie_Anime: [
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
      EnumerationFulltypeVideo.Serie_Drama: [
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
      ]
    };
  }
}
