import 'package:flutter/material.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Film.dart';

class AnimeFilm extends VideoFilm {
  String _studio = "";
  String get studio => this._studio;
  void set studio(String value) {
    this._studio = value;
  }

  AnimeFilm({required VideoFilm videoFilm, String studio = ""})
      : super(
            video: Video(
                titre: videoFilm.titre,
                description: videoFilm.description,
                duree: videoFilm.duree,
                date_parution: videoFilm.dateParution,
                lien_affiche: videoFilm.lienAffiche)) {
    this._studio = studio;
  }

  static AnimeFilm parseToAnimeFilm(
          {required String titre,
          required String description,
          required TimeOfDay duree,
          required DateTime dateParution,
          required String lienAffiche,
          required String studio}) =>
      AnimeFilm(
          videoFilm: VideoFilm(
              video: Video(
                  titre: titre,
                  description: description,
                  duree: duree,
                  date_parution: dateParution,
                  lien_affiche: lienAffiche)),
          studio: studio);
}
