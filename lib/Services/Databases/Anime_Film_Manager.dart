import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Anime_Film.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Film.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';

class AnimeFilmManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) sync* {
    Iterator iterator_source_animefilm = item[0].iterator;
    int iteration = 0;
    while (iterator_source_animefilm.moveNext()) {
      yield {
        "index": iteration,
        "Video": AnimeFilm.parseToAnimeFilm(
            titre: iterator_source_animefilm.current["Titre"],
            description: iterator_source_animefilm.current["Description"] ?? "",
            duree: iterator_source_animefilm.current["Duree"] != null
                ? TimeOfDay(
                    hour: int.parse(iterator_source_animefilm.current["Duree"]
                        .split(":")[0]),
                    minute: int.parse(iterator_source_animefilm.current["Duree"]
                        .split(":")[1]))
                : null,
            dateParution:
                iterator_source_animefilm.current["Date_Parution"] != null
                    ? DateTime.tryParse(
                        iterator_source_animefilm.current["Date_Parution"])
                    : null,
            lienAffiche:
                iterator_source_animefilm.current["Lien_Affiche"] ?? "",
            studio: iterator_source_animefilm.current["Studio"] ?? "")
      };
      iteration += 1;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> records_animes_films = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche,Animes_Films.Studio from Animes_Films inner join Videos_Films on Animes_Films.Titre=Videos_Films.Titre inner join Videos on Animes_Films.Titre=Videos.Titre");
    //DataInitialize.closeConnection();
    return records_animes_films;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    Map<String, dynamic> record = (await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche,Animes_Films.Studio from Animes_Films inner join Videos_Films on Animes_Films.Titre=Videos_Films.Titre inner join Videos on Animes_Films.Titre=Videos.Titre where Animes_Films.Titre=?",
        [fields["Titre"]]))[0];
    return AnimeFilm(
        videoFilm: VideoFilm(
            video: Video(
                titre: record[0]["Titre"],
                description: record[0]["Description"],
                duree: record[0]["Duree"],
                date_parution: record[0]["Date_Parution"],
                lien_affiche: record[0]["Lien_Affiche"])));
  }

  @override
  Future<bool> insert(BaseModel model) async {
    try {
      Database database = await DataInitialize.getDatabase();
      await database.execute(
          "insert or ignore into Animes_Films(Titre,Studio) values(?,?)",
          [(model as AnimeFilm).titre, (model as AnimeFilm).studio]);
    } on DatabaseException catch (exception_database) {
      return false;
    } finally {}
    return true;
  }
}
