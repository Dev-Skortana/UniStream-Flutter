import 'package:nameof_annotation/nameof_annotation.dart';

import 'package:flutter/material.dart';
import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';
import 'Templates/Base_Model.dart';

part 'Models_MetaData/Video.nameof.dart';

@nameof
class Video extends BaseModel {
  @protected
  String _titre = "";
  String _description = "";
  TimeOfDay? _duree;
  DateTime? _dateParution;
  String _lienAffiche = "";
  Iterable _pays = [];
  Iterable _genres = [];
  Iterable _realisateurs = [];

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

  Iterable get pays => this._pays;
  void set pays(Iterable value) {
    this._pays = value;
  }

  Iterable get genres => this._genres;
  void set genres(Iterable value) {
    this._genres = value;
  }

  Iterable get realisateurs => this._realisateurs;
  void set realisateurs(Iterable value) {
    this._realisateurs = value;
  }

  Video(
      {String titre = "",
      String description = "",
      TimeOfDay? duree,
      DateTime? date_parution,
      String lien_affiche = "",
      Iterable pays = const [],
      Iterable genres = const [],
      Iterable realisateurs = const []})
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
          required TimeOfDay? duree,
          required DateTime? dateParution,
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
        duree: TimeOfDay(hour: 0, minute: 0),
        date_parution: null,
        lien_affiche: "",
      );
}
