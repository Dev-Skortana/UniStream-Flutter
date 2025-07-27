import 'package:flutter/material.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Serie.dart';

class Serie extends VideoSerie {
  Serie({required VideoSerie videoSerie})
      : super(
            video: Video(
                titre: videoSerie.titre,
                description: videoSerie.description,
                duree: videoSerie.duree,
                date_parution: videoSerie.dateParution,
                lien_affiche: videoSerie.lienAffiche)) {}
  static Serie parseToSerie(
          {required String titre,
          required String description,
          required TimeOfDay? duree,
          required DateTime? dateParution,
          required String lienAffiche}) =>
      Serie(
          videoSerie: VideoSerie(
              video: Video(
                  titre: titre,
                  description: description,
                  duree: duree,
                  date_parution: dateParution,
                  lien_affiche: lienAffiche)));
}
