import 'package:unistream/Models/Anime_Film.dart';
import 'package:unistream/Models/Anime_Serie.dart';
import 'package:unistream/Models/Detail_Video_Serie.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Film.dart';
import 'package:unistream/Models/Video_Serie.dart';

class MetaDataFetch {
  late Video InstanceModel;

  MetaDataFetch(this.InstanceModel);

  List<String> getFieldsNamesOfModel() => <String>[
        ...this._getFieldsOfVideo(),
        ...this._getFieldsChildsOfVideo(),
        ...this._getFieldsOfTopClass()
      ];

  List<String> _getFieldsOfVideo() => <String>[
        NameofVideo.propertyGetTitre,
        NameofVideo.propertyGetDescription,
        NameofVideo.propertyGetDuree,
        NameofVideo.propertyGetDateParution,
        NameofVideo.propertyGetLienAffiche,
        NameofVideo.propertyGetPays,
        NameofVideo.propertyGetGenres,
        NameofVideo.propertyGetRealisateurs
      ];
  List<String> _getFieldsChildsOfVideo() {
    if (this._IsObjectInheritFromSerieBase()) {
      return <String>[
        NameofDetailVideoSerie.propertyGetSaison,
        NameofDetailVideoSerie.propertyGetEpisode
      ];
    }
    if (this._IsObjectInheritFromFilmBase()) {}
    return <String>[];
  }

  List<String> _getFieldsOfTopClass() {
    if (this._IsObjectOfAnimer()) {
      return <String>[NameofAnimeSerie.propertyGetStudio];
    }
    return [];
  }

  bool _IsObjectInheritFromSerieBase() => this.InstanceModel is VideoSerie;
  bool _IsObjectInheritFromFilmBase() => this.InstanceModel is VideoFilm;
  bool _IsObjectOfAnimer() =>
      this.InstanceModel.runtimeType == AnimeFilm ||
      this.InstanceModel.runtimeType == AnimeSerie;
}
