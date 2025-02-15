import 'package:unistream/Models/Templates/Base_Model.dart';

class Realisateur extends BaseModel {
  String _nom = "";
  String get nom => this._nom;
  void set nom(String value) {
    this._nom = value;
  }

  Realisateur({String nom = ""}) {
    this._nom = nom;
  }

  static Realisateur parseToRealisateur({required String nom}) =>
      Realisateur(nom: nom);
}
