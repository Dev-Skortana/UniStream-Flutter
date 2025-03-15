import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Film.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Film.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';

class FilmManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) sync* {
    Iterator iterator_source_film = item[0].iterator;
    int iteration = 0;
    while (iterator_source_film.moveNext()) {
      yield {
        "index": iteration,
        "Video": Film.parseToFilm(
            titre: iterator_source_film.current["Titre"],
            description: iterator_source_film.current["Description"] ?? "",
            duree: iterator_source_film.current["Duree"] ?? TimeOfDay.now(),
            dateParution:
                iterator_source_film.current["Date_Parution"] ?? DateTime.now(),
            lienAffiche: iterator_source_film.current["Lien_Affiche"] ?? "")
      };
      iteration += 1;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> records_films = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Films inner join Videos_Films on Films.Titre=Videos_Films.Titre inner join Videos on Films.Titre=Videos.Titre");
    //DataInitialize.closeConnection();

    return records_films;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    Map<String, dynamic> record = (await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Films inner join Videos_Films on Films.Titre=Videos_Films.Titre inner join Videos on Films.Titre=Videos.Titre where Films.Titre=",
        [fields["Titre"]]))[0];
    return Film(
      videoFilm: VideoFilm(
          video: Video(
              titre: record[0]["Titre"],
              description: record[0]["Description"],
              duree: record[0]["Duree"],
              date_parution: record[0]["Date_Parution"],
              lien_affiche: record[0]["Lien_Affiche"])),
    );
    ;
  }

  @override
  Future<void> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute("insert or ignore into Films(Titre) values(?)",
        [(model as Film).titre]);
  }
}
