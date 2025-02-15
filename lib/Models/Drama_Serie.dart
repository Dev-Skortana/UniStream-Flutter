import 'package:flutter/material.dart';
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

  static DramaSerie parseToDramaSerie(
          {required String titre,
          required String description,
          required TimeOfDay duree,
          required DateTime dateParution,
          required String lienAffiche}) =>
      DramaSerie(
        videoSerie: VideoSerie(
            video: Video(
                titre: titre,
                description: description,
                duree: duree,
                date_parution: dateParution,
                lien_affiche: lienAffiche)),
      );
}
