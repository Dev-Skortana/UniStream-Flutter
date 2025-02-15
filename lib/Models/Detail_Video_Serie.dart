import 'package:unistream/Models/Templates/Base_Model.dart';

class DetailVideoSerie extends BaseModel {
  String _titre = "";
  int _saison = 0;
  int _episode = 0;

  String get titre => this._titre;
  void set titre(String value) {
    this._titre = value;
  }

  int get saison => this._saison;
  void set saison(int value) {
    this._saison = value;
  }

  int get episode => this._episode;
  void set episode(int value) {
    this._episode = value;
  }

  DetailVideoSerie(
      {required String titreVideoSerie,
      required int saison,
      required int episode})
      : super() {
    this._titre = titreVideoSerie;
    this._saison = saison;
    this._episode = episode;
  }

  static DetailVideoSerie parseToDetailVideoSerie(
          {required String titre_videoserie,
          required int saison,
          required int episode}) =>
      DetailVideoSerie(
          titreVideoSerie: titre_videoserie, saison: saison, episode: episode);
}
