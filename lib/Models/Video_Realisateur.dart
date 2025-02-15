import 'package:unistream/Models/Templates/Base_Model.dart';

class VideoRealisateur extends BaseModel {
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

  VideoRealisateur({required String titre, required String nom}) : super() {
    this._titre = titre;
    this._nom = nom;
  }

  static VideoRealisateur parseToVideoRealisateur(
          {required String titre, required String nom}) =>
      VideoRealisateur(titre: titre, nom: nom);
}
