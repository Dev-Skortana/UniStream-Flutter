import 'package:nameof_annotation/nameof_annotation.dart';

import 'package:flutter/material.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Serie.dart';

part 'Models_MetaData/Anime_Serie.nameof.dart';

@nameof
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

  static AnimeSerie parseToAnimeSerie(
          {required String titre,
          required String description,
          required TimeOfDay? duree,
          required DateTime? dateParution,
          required String lienAffiche,
          required String studio}) =>
      AnimeSerie(
          videoSerie: VideoSerie(
              video: Video(
                  titre: titre,
                  description: description,
                  duree: duree,
                  date_parution: dateParution,
                  lien_affiche: lienAffiche)),
          studio: studio);
}
