import 'package:flutter/material.dart';

import 'Templates/Base_Model.dart';

class Video extends BaseModel {
  @protected
  String _titre = "";

  String _description = "";
  TimeOfDay? _duree;
  DateTime? _dateParution;
  String _lienAffiche = "";

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

  Video(
      {String titre = "",
      String description = "",
      TimeOfDay? duree,
      DateTime? date_parution,
      String lien_affiche = ""})
      : super() {
    this._titre = titre;
    this._description = description;
    this._duree = duree;
    this._dateParution = date_parution;
    this._lienAffiche = lien_affiche;
  }
}
