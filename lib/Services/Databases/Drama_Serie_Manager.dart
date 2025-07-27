import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Drama_Film.dart';
import 'package:unistream/Models/Drama_Serie.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Serie.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';

class DramaSerieManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) sync* {
    Iterator iterator_source_dramaserie = item[0].iterator;
    int iteration = 0;
    while (iterator_source_dramaserie.moveNext()) {
      yield {
        "index": iteration,
        "Video": DramaSerie.parseToDramaSerie(
          titre: iterator_source_dramaserie.current["Titre"],
          description: iterator_source_dramaserie.current["Description"] ?? "",
          duree: iterator_source_dramaserie.current["Duree"] != null
              ? TimeOfDay(
                  hour: int.parse(iterator_source_dramaserie.current["Duree"]
                      .split(":")[0]),
                  minute: int.parse(iterator_source_dramaserie.current["Duree"]
                      .split(":")[1]))
              : null,
          dateParution:
              iterator_source_dramaserie.current["Date_Parution"] != null
                  ? DateTime.tryParse(
                      iterator_source_dramaserie.current["Date_Parution"])
                  : null,
          lienAffiche: iterator_source_dramaserie.current["Lien_Affiche"] ?? "",
        )
      };
      iteration += 1;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> records_dramas_series = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Dramas_Series inner join Videos_Series on Dramas_Series.Titre=Videos_Series.Titre inner join Videos on Dramas_Series.Titre=Videos.Titre");
    //DataInitialize.closeConnection();

    return records_dramas_series;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    Map<String, dynamic> record = (await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Dramas_Series inner join Videos_Series on Dramas_Series.Titre=Videos_Series.Titre inner join Videos on Dramas_Series.Titre=Videos.Titre where Dramas_Series.Titre=?",
        [fields["Titre"]]))[0];
    return DramaSerie(
      videoSerie: VideoSerie(
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
  Future<bool> insert(BaseModel model) async {
    try {
      Database database = await DataInitialize.getDatabase();
      await database.execute(
          "insert or ignore into Dramas_Series(Titre) values(?)",
          [(model as DramaSerie).titre]);
    } on DatabaseException catch (exception_database) {
      return false;
    } finally {}
    return true;
  }
}
