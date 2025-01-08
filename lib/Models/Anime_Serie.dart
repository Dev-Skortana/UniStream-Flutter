import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Serie.dart';

class AnimeSerie extends VideoSerie {
  String _studio = "";
  String get studio => this._studio;
  void set studio(String value) {
    this._studio = value;
  }

  AnimeSerie({required VideoSerie videoSerie, String studio = ""})
      : super(
            video: Video(
                titre: videoSerie.titre,
                description: videoSerie.description,
                duree: videoSerie.duree,
                date_parution: videoSerie.dateParution,
                lien_affiche: videoSerie.lienAffiche)) {
    this._studio = studio;
  }
}
