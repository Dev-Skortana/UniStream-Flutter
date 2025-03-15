import 'package:flutter/material.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Film.dart';

class Film extends VideoFilm {
  Film({required VideoFilm videoFilm})
      : super(
            video: Video(
                titre: videoFilm.titre,
                description: videoFilm.description,
                duree: videoFilm.duree,
                date_parution: videoFilm.dateParution,
                lien_affiche: videoFilm.lienAffiche)) {}

  static Film parseToFilm(
          {required String titre,
          required String description,
          required TimeOfDay duree,
          required DateTime dateParution,
          required String lienAffiche}) =>
      Film(
          videoFilm: VideoFilm(
              video: Video(
                  titre: titre,
                  description: description,
                  duree: duree,
                  date_parution: dateParution,
                  lien_affiche: lienAffiche)));
}
