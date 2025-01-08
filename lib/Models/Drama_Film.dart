import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Film.dart';

class DramaFilm extends VideoFilm {
  DramaFilm({required videoFilm})
      : super(
            video: Video(
                titre: videoFilm.titre,
                description: videoFilm.description,
                duree: videoFilm.duree,
                date_parution: videoFilm.dateParution,
                lien_affiche: videoFilm.lienAffiche)) {}
}
