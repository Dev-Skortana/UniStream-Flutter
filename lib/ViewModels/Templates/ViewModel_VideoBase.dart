import 'package:flutter/material.dart';
import 'package:unistream/Helpers/Meta_Data_Fetch.dart';
import 'package:unistream/Models/Genre.dart';
import 'package:unistream/Models/Pays.dart';
import 'package:unistream/Models/Realisateur.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Serie.dart';
import 'package:unistream/Services/Databases/Special_Management.dart';
import 'package:unistream/Services/Databases/Video_Genre_Manager.dart';
import 'package:unistream/Services/Databases/Video_Pays_Manager.dart';
import 'package:unistream/Services/Databases/Video_Realisateur_Manager.dart';
import 'package:unistream/Services/Features/Link_Watch_Video/Result_Link_Watch_Of_Video.dart';
import 'package:unistream/Services/Features/Search_Data/Manager_Set_Search.dart';
import 'package:unistream/Services/Features/Search_Data/Set_Search.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';
import 'package:unistream/Models/Models_MetaData/Meta_Data.dart' as meta_data;
import 'package:unistream/ViewModels/ViewModel_AnimeFilm.dart';
import 'package:unistream/ViewModels/ViewModel_AnimeSerie.dart';

class ViewmodelVideobase {
  late Iterable videosFromDictionnary;
  late Map<String, dynamic> _callBackGetVideos;
  late dynamic _callBackGetVideosFiltered;
  late bool _isCallBackGetVideosFilteredToUsed;

  List _ListVideosGenres = [];
  List _ListVideosPays = [];
  List _ListVideosRealisateurs = [];
  Map<String, dynamic> video = {"Index": 0, "Video": Video.getEmptyVideo()};

  late int index = 0;
  late int TotalCount;

  ViewmodelVideobase(Map<String, dynamic> dictionnary_methode_and_args) {
    _callBackGetVideos = dictionnary_methode_and_args;
    _isCallBackGetVideosFilteredToUsed = false;

    videosFromDictionnary = dictionnary_methode_and_args["method"](
        [...dictionnary_methode_and_args["args"]]);
    _InitializeSubList();
    GetVideoFirst();
    TotalCount = Count(videosFromDictionnary);
  }

  void _InitializeSubList() async {
    _ListVideosGenres = await VideoGenreManager().getList({});
    _ListVideosPays = await VideoPaysManager().getList({});
    _ListVideosRealisateurs = await VideoRealisateurManager().getList({});
  }

  int Count(Iterable generator) => generator.length;

  Iterable _getGenres() => VideoGenreManager().GetGen(_ListVideosGenres);
  Iterable _GetPays() => VideoPaysManager().GetGen(_ListVideosPays);
  Iterable _GetRealisateurs() =>
      VideoRealisateurManager().GetGen(_ListVideosRealisateurs);

  Map<String, dynamic> _ProcessFillsVideo(Map<String, dynamic> video) {
    _FillVideoWithGenres(video);
    _FillVideoWithPays(video);
    _FillVideoWithRealisateurs(video);
    return video;
  }

  void _FillVideoWithGenres(Map<String, dynamic> video) {
    video["Video"].genres = _getGenForVideoWithGenres(video);
  }

  Iterable _getGenForVideoWithGenres(Map<String, dynamic> video) sync* {
    for (var video_genre in _getGenres()) {
      if (video["Video"].titre == video_genre["Video"].titre) {
        yield Genre(nom: video_genre["Video"].nom);
      }
    }
  }

  void _FillVideoWithPays(Map<String, dynamic> video) {
    video["Video"].pays = _getGenForVideoWithPays(video);
  }

  Iterable _getGenForVideoWithPays(Map<String, dynamic> video) sync* {
    for (var video_pays in _GetPays()) {
      if (video["Video"].titre == video_pays["Video"].titre) {
        yield Pays(nom: video_pays["Video"].nom);
      }
    }
  }

  void _FillVideoWithRealisateurs(Map<String, dynamic> video) {
    video["Video"].realisateurs = _getGenForVideoWithRealisateurs(video);
  }

  Iterable _getGenForVideoWithRealisateurs(Map<String, dynamic> video) sync* {
    for (var video_realisateur in _GetRealisateurs()) {
      if (video["Video"].titre == video_realisateur["Video"].titre) {
        yield Realisateur(nom: video_realisateur["Video"].nom);
      }
    }
  }

  void GetVideoNext() {
    if (isVideosAndCurrentVideoHasValue()) {
      index += 1;
      if (index > TotalCount - 1) {
        index = 0;
      }
      GetVideo();
    }
  }

  void GetVideoPrevious() {
    if (isVideosAndCurrentVideoHasValue()) {
      index -= 1;
      if (index < 0) {
        index = (TotalCount - 1);
      }
      GetVideo();
    }
  }

  void GetVideoFirst() {
    index = 0;
    GetVideo();
  }

  void GetVideoLast() {
    index = TotalCount - 1;
    GetVideo();
  }

  bool isVideosAndCurrentVideoHasValue() =>
      _isVideosHasValues() && IsVideoHasValue(video: video["Video"]);

  void GetVideo() {
    dynamic callback = getCallBackNeeded();
    void fetching(dynamic callback_result) {
      for (var video in callback_result) {
        if (index == video["index"]) {
          video = _getVideoFilled(video);
          this.video = video;
        }
      }
    }

    dynamic callback_result = Object();
    if (_isCallBackGetVideosFilteredToUsed == false) {
      callback_result = callback["method"]([...callback["args"]]);
    } else {
      callback_result = callback();
    }
    fetching(callback_result);
  }

  Map<String, dynamic> _getVideoFilled(Map<String, dynamic> video) {
    video = _ProcessFillsVideo(video);
    if (this is ViewmodelSeriebase) {
      (this as ViewmodelSeriebase).FillVideoSerieWithDetails(video);
    }
    return video;
  }

  dynamic getCallBackNeeded() {
    return _isCallBackGetVideosFilteredToUsed == false
        ? _callBackGetVideos
        : _callBackGetVideosFiltered;
  }

  bool _isVideosHasValues() => TotalCount > 0;
  bool IsVideoHasValue({required Video video}) => video != null;

  Iterable GetVideosOfSearch(SetSearch set_of_search) {
    index = 0;

    Iterable<Map<String, dynamic>> get_generator_filtered() sync* {
      int _index = 0;
      for (var video
          in _callBackGetVideos["method"]([..._callBackGetVideos["args"]])) {
        video = this._getVideoFilled(video);
        if (this._GetFilter(video["Video"], set_of_search)) {
          yield {"index": _index, "Video": video["Video"]};
          _index += 1;
        }
      }
    }

    final List<Map<String, dynamic>> elements_filtered_in_list =
        get_generator_filtered().toList();

    Iterable<Map<String, dynamic>> get_generator_result() sync* {
      for (var element_result in elements_filtered_in_list) {
        yield element_result;
      }
    }

    this.TotalCount = this.Count(get_generator_result());
    Iterable new_videos = get_generator_result();

    this.video = elements_filtered_in_list.isNotEmpty ? new_videos.first : {};
    this._callBackGetVideosFiltered = get_generator_result;
    this._isCallBackGetVideosFilteredToUsed = true;
    return new_videos;
  }

  bool _GetFilter(Video video, SetSearch set_of_search) {
    late Iterable set_data__that_include_valuesearch;

    if (["saison", "episode"].contains(set_of_search.field)) {
      set_data__that_include_valuesearch = this
          .getDatasinDetailsSeries(video as VideoSerie, set_of_search.field)
          .toList();
    } else if (["realisateurs", "genres", "pays"]
        .contains(set_of_search.field)) {
      final Map<String, dynamic> map_method_needed = {
        "realisateurs": this._GetRealisateurs,
        "genres": this._getGenres,
        "pays": this._GetPays
      };
      set_data__that_include_valuesearch = this.getDatasAdditionalInVideo(
          map_method_needed[set_of_search.field], video.titre);
    } else {
      final Map<String, dynamic> map_stringmember_to_member = {
        "titre": video.titre,
        "description": video.description,
        "duree": video.duree,
        "dateParution": video.dateParution,
        "lienAffiche": video.lienAffiche
      };
      if ([ViewmodelAnimefilm, ViewmodelAnimeserie]
          .contains(this.runtimeType)) {
        map_stringmember_to_member
            .addAll({"studio": (video as dynamic).studio});
      }

      set_data__that_include_valuesearch = [
        map_stringmember_to_member[set_of_search.field]
      ];
    }
    return ManagerSetSearch(set_of_search)
        .EvaluateCondition(set_data__that_include_valuesearch);
  }

  Iterable getDatasinDetailsSeries(VideoSerie video, String field) {
    final Iterable results = video.detailsVideosSeries!
        .where((detail) => detail.titre == video.titre);
    return results
        .map((detail) => field == "saison" ? detail.saison : detail.episode);
  }

  Iterable getDatasAdditionalInVideo(
      Iterable Function() function, String titre_video) {
    final Iterable results =
        function().where((data) => data["Video"].titre == titre_video);

    return results.map((data) => data["Video"].nom.trim().toUpperCase());
  }

  Future<List<Map<String, String>>> getManyResultLinkWatchOfVideo(
      Map<String, String> maps) async {
    return await ResultLinkWatchOfVideo().getManyResultLinkWatchOfVideo(maps);
  }

  List<String> getFieldsSearch() {
    return MetaDataFetch(video["Video"]).getFieldsNamesOfModel();
  }

  Future<String> getTypeOfFieldSelected(String name_field) async {
    meta_data.MetaData metaData =
        await SpecialManagement.getMetaDataOnVideo(name_field);
    return metaData.typeField;
  }
}
