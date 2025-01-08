import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Serie.dart';

class DramaSerie extends VideoSerie {
  DramaSerie({required VideoSerie videoSerie})
      : super(
            video: Video(
                titre: videoSerie.titre,
                description: videoSerie.description,
                duree: videoSerie.duree,
                date_parution: videoSerie.dateParution,
                lien_affiche: videoSerie.lienAffiche)) {}
}
