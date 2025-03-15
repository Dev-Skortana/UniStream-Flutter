import 'package:flutter/material.dart';

import 'Templates/Base_Model.dart';

class Video extends BaseModel {
  @protected
  String _titre = "";
  String _description = "";
  TimeOfDay? _duree;
  DateTime? _dateParution;
  String _lienAffiche = "";
  Iterable? _pays = [];
  Iterable? _genres = [];
  Iterable? _realisateurs = [];

  String get titre => _titre;
  void set titre(String value) {
    this._titre = value;
  }

  String get description => this._description;
  void set description(String value) {
    this._description = value;
  }

  TimeOfDay? get duree => this._duree;
  void set duree(TimeOfDay? value) {
    this._duree = value;
  }

  DateTime? get dateParution => this._dateParution;
  void set date_parution(DateTime? value) {
    this._dateParution = value;
  }

  String get lienAffiche => this._lienAffiche;
  void set lienAffiche(String value) {
    this._lienAffiche = value;
  }

  Iterable? get pays => this._pays;
  void set pays(Iterable? value) {
    this._pays = value;
  }

  Iterable? get genres => this._genres;
  void set genres(Iterable? value) {
    this._genres = value;
  }

  Iterable? get realisateurs => this._realisateurs;
  void set realisateurs(Iterable? value) {
    this._realisateurs = value;
  }

  Video(
      {String titre = "",
      String description = "",
      TimeOfDay? duree,
      DateTime? date_parution,
      String lien_affiche = "",
      Iterable? pays,
      Iterable? genres,
      Iterable? realisateurs})
      : super() {
    this._titre = titre;
    this._description = description;
    this._duree = duree;
    this._dateParution = date_parution;
    this._lienAffiche = lien_affiche;
  }

  static Video parseToVideo(
          {required String titre,
          required String description,
          required TimeOfDay duree,
          required DateTime dateParution,
          required String lienAffiche}) =>
      Video(
          titre: titre,
          description: description,
          duree: duree,
          date_parution: dateParution,
          lien_affiche: lienAffiche);

  static Video getEmptyVideo() => Video(
        titre: "",
        description: "",
        duree: TimeOfDay.now(),
        date_parution: DateTime.now(),
        lien_affiche:
            "assets/images/video_posters/visuals-NotFound-unsplash.jpg",
      );
}
