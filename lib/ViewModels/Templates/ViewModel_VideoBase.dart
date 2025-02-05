import 'package:flutter/material.dart';
import 'package:unistream/Models/Genre.dart';
import 'package:unistream/Models/Pays.dart';
import 'package:unistream/Models/Realisateur.dart';
import 'package:unistream/Services/Databases/Special_Management.dart';
import 'package:unistream/Services/Databases/Video_Genre_Manager.dart';
import 'package:unistream/Services/Databases/Video_Pays_Manager.dart';
import 'package:unistream/Services/Databases/Video_Realisateur_Manager.dart';
import 'package:unistream/Services/Features/Search_Data/Set_Search.dart';
import 'package:unistream/ViewModels/Templates/ViewModel_SerieBase.dart';

class ViewmodelVideobase {
  late Iterable videosFromDictionnary;
  late Map<String, dynamic> _callBackGetVideos;
  late bool _callBackGetVideosFiltered;

  late List _ListVideosGenres;
  late List _ListVideosPays;
  late List _ListVideosRealisateurs;
  late Map<String, dynamic> video;

  late int index = 0;
  late int TotalCount;

  ViewmodelVideobase(Map<String, dynamic> dictionnary_methode_and_args) {
    this._callBackGetVideos = dictionnary_methode_and_args;
    this._callBackGetVideosFiltered = false;

    this.videosFromDictionnary = dictionnary_methode_and_args["method"](
        [...dictionnary_methode_and_args["args"]]);
  }

  void _InitializeSubList() async {
    this._ListVideosGenres = await VideoGenreManager().getList({});
    this._ListVideosPays = await VideoPaysManager().getList({});
    this._ListVideosRealisateurs = await VideoRealisateurManager().getList({});
  }

  int Count(Iterable generator) => generator.length;

  Iterable _getGenres() => VideoGenreManager().GetGen(this._ListVideosGenres);
  Iterable _GetPays() => VideoPaysManager().GetGen(this._ListVideosPays);
  Iterable _GetRealisateurs() =>
      VideoRealisateurManager().GetGen(this._ListVideosRealisateurs);

  Map<String, dynamic> _ProcessFillsVideo(Map<String, dynamic> video) {
    this._FillVideoWithGenres(video);
    this._FillVideoWithPays(video);
    this._FillVideoWithRealisateurs(video);
    return video;
  }

  void _FillVideoWithGenres(Map<String, dynamic> video) {
    this.video["Video"].Genres = this._getGenForVideoWithGenres(video);
  }

  Iterable _getGenForVideoWithGenres(Map<String, dynamic> video) sync* {
    for (var video_genre in this._getGenres()) {
      if (video["Video"].Titre == video_genre["Video"].Titre) {
        yield Genre(nom: video_genre["Video"].Nom);
      }
    }
  }

  void _FillVideoWithPays(Map<String, dynamic> video) {
    this.video["Video"].Pays = this._getGenForVideoWithPays(video);
  }

  Iterable _getGenForVideoWithPays(Map<String, dynamic> video) sync* {
    for (var video_pays in this._GetPays()) {
      if (video["Video"].Titre == video_pays["Video"].Titre) {
        yield Pays(nom: video_pays["Video"].Nom);
      }
    }
  }

  void _FillVideoWithRealisateurs(Map<String, dynamic> video) {
    this.video["Video"].Realisateurs =
        this._getGenForVideoWithRealisateurs(video);
  }

  Iterable _getGenForVideoWithRealisateurs(Map<String, dynamic> video) sync* {
    for (var video_realisateur in this._GetRealisateurs()) {
      if (video["Video"].Titre == video_realisateur["Video"].Titre) {
        yield Realisateur(nom: video_realisateur["Video"].Nom);
      }
    }
  }

  void GetVideoNext() {
    if (this.isVideosAndCurrentVideoHasValue()) {
      this.index += 1;
      if (this.index > this.TotalCount - 1) {
        this.index = 0;
      }
      this.GetVideo();
    }
  }

  void GetVideoPrevious() {
    if (this.isVideosAndCurrentVideoHasValue()) {
      this.index -= 1;
      if (this.index < 0) {
        this.index = (this.TotalCount - 1);
        this.GetVideo();
      }
    }
  }

  void GetVideoFirst() {
    this.index = 0;
    this.GetVideo();
  }

  void GetVideoLast() {
    this.index = this.TotalCount - 1;
    this.GetVideo();
  }

  bool isVideosAndCurrentVideoHasValue() =>
      this._isVideosHasValues() &&
      this.IsVideoHasValue(video: this.video["Video"]);

  void GetVideo() {
    dynamic callback = this.getCallBackNeeded();
    void fetching(dynamic callback_result) {
      for (var video in callback_result) {
        if (this.index == this.video["Video"]) {
          this.video = this._getVideoFilled(video);
        }
      }
    }

    dynamic callback_result = Object();
    if (this._callBackGetVideosFiltered == null) {
      callback_result = callback["method"]([...callback["args"]]);
    } else {
      callback_result = callback();
    }
  }

  Map<String, dynamic> _getVideoFilled(Map<String, dynamic> video) {
    video = this._ProcessFillsVideo(video);
    if (this is ViewmodelSeriebase) {
      (this as ViewmodelSeriebase).FillVideoSerieWithDetails(video);
    }
    return video;
  }

  dynamic getCallBackNeeded() {
    return this._callBackGetVideosFiltered == null
        ? this._callBackGetVideos
        : this._callBackGetVideosFiltered;
  }

  bool _isVideosHasValues() => this.TotalCount > 0;
  bool IsVideoHasValue({required Map<String, dynamic> video}) => video != null;

  Iterable GetVideosOfSearch(SetSearch set_of_search) {
    /* à completer !!! */
    return [];
  }

  bool _GetFilter(Map<String, dynamic> video, SetSearch set_of_search) {
    /* à completer !!! */
    return true;
  }

  Type getTypeOfCallbacknedeed() =>
      this._callBackGetVideosFiltered == null ? Map<String, dynamic> : Function;
}
