import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';
import 'package:unistream/Helpers/Duration_Util.dart';

class VideoManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) sync* {
    Iterator iterator_source_video = item.iterator;
    int iteration = 0;
    while (iterator_source_video.moveNext()) {
      yield {
        "index": iteration,
        "Video": Video.parseToVideo(
            titre: iterator_source_video.current["Titre"],
            description: iterator_source_video.current["Description"],
            duree: iterator_source_video.current["Duree"],
            dateParution: DateTime.tryParse(
                iterator_source_video.current["Date_Parution"]),
            lienAffiche: iterator_source_video.current["Lien_Affiche"])
      };
      iteration += 1;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> records_videos = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Films inner join Videos_Films on Films.Titre=Videos_Films.Titre inner join Videos on Films.Titre=Videos.Titre");
    //DataInitialize.closeConnection();

    return records_videos;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    Map<String, dynamic> record = (await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Videos where Videos.Titre=?",
        [fields["Titre"]]))[0];
    return BaseModel();
  }

  @override
  Future<bool> insert(BaseModel model) async {
    //TODO
    try {
      Video video = model as Video;
      String? duree_into_caracteres =
          DurationUtil.getDurationIntoString(video.duree);
      String? date_parution_into_caracteres =
          video.dateParution?.toIso8601String().split("T").firstOrNull;
      Database database = await DataInitialize.getDatabase();
      await database.execute(
          "insert or ignore into Videos(Titre,Description,Duree,Date_Parution,Lien_Affiche) values(?,?,time(?),?,?)",
          [
            video.titre,
            video.description,
            duree_into_caracteres,
            date_parution_into_caracteres,
            video.lienAffiche
          ]);
    } on DatabaseException catch (exception_database) {
      return false;
    } finally {}
    return true;
  }

  void UpdateFieldPoster(String title, String path_poster) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "update Videos set Lien_Affiche=? where Titre=?", [path_poster, title]);
  }
}
