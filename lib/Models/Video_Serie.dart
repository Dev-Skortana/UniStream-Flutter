import 'package:unistream/Models/Video.dart';

class VideoSerie extends Video {
  Iterable? _detailsVideosSeries;

  Iterable? get detailsVideosSeries => _detailsVideosSeries;
  void set detailsVideosSeries(Iterable? value) {
    this._detailsVideosSeries = value;
  }

  VideoSerie({required Video video, Iterable? details_videos_series})
      : super(
            titre: video.titre,
            description: video.description,
            duree: video.duree,
            date_parution: video.dateParution,
            lien_affiche: video.lienAffiche) {
    this._detailsVideosSeries = details_videos_series ?? [];
  }
}
