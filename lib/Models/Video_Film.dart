import 'package:unistream/Models/Video.dart';

class VideoFilm extends Video {
  VideoFilm({required Video video})
      : super(
            titre: video.titre,
            description: video.description,
            duree: video.duree,
            date_parution: video.dateParution,
            lien_affiche: video.lienAffiche) {}
}
