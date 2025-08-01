import 'package:unistream/Models/Templates/Base_Model.dart';

class VideoGenre extends BaseModel {
  String _titre = "";
  String _nom = "";

  String get titre => this._titre;
  void set titre(String value) {
    this._titre = value;
  }

  String get nom => this._nom;
  void set nom(String value) {
    this._nom = value;
  }

  VideoGenre({required String titre, required String nom}) : super() {
    this._titre = titre;
    this._nom = nom;
  }

  static VideoGenre parseToVideoGenre(
          {required String titre, required String nom}) =>
      VideoGenre(titre: titre, nom: nom);
}
