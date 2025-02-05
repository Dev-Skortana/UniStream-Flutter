import 'dart:async';

import 'package:collection/collection.dart';

import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Meta_Data.dart';
import 'dart:typed_data';

class SpecialManagement {
  static Future<Iterator<Map<String, dynamic>>>
      getVideosOnTheLastTwelveMonths() async {
    const String chaine_condition = "";
    //"where date(Videos.Date_Parution)>=date('now','-1 year') and date(Videos.Date_Parution)<=date('now')";
    const String chaine_order = "order by Videos.Titre asc";
    Iterable<Map<String, dynamic>> iterator_videos_films =
        await SpecialManagement.getVideosFilmsOnTheLastTwelveMonths(
            chaine_condition, chaine_order);
    Iterable<Map<String, dynamic>> iterator_videos_series =
        await SpecialManagement.getVideosSeriesOnTheLastTwelveMonths(
            chaine_condition, chaine_order);

    return CombinedIterableView([iterator_videos_films, iterator_videos_series])
        .iterator;
  }

  static Future<Iterable<Map<String, dynamic>>>
      getVideosFilmsOnTheLastTwelveMonths(
          String chaine_condition, String chaine_order) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> Records_films = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Videos_Films inner join Videos on Videos_Films.Titre=Videos.Titre ${chaine_condition} ${chaine_order}");

    //DataInitialize.closeConnection();
    return Records_films;
  }

  static Future<Iterable<Map<String, dynamic>>>
      getVideosSeriesOnTheLastTwelveMonths(
          String chaine_condition, String chaine_order) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> Records_series = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche,Videos_Series.Titre Titre_Serie from Videos_Series inner join Videos on Videos_Series.Titre=Videos.Titre ${chaine_condition} ${chaine_order}");
    //DataInitialize.closeConnection();

    return Records_series;
  }

  static Future<int> getTotalVideosFilmsOnTheLastTwelveMonths() async {
    Database database = await DataInitialize.getDatabase();
    int count = Sqflite.firstIntValue(await database.rawQuery(
            "select count(*) from Videos_Films inner join Videos on Videos_Films.Titre=Videos.Titre where date(Videos.Date_Parution)>=date('now','-1 year') and date(Videos.Date_Parution)<=date('now')")) ??
        0;
    //DataInitialize.closeConnection();
    return count;
  }

  static Future<int> getTotalVideosSeriesOnTheLastTwelveMonths() async {
    Database database = await DataInitialize.getDatabase();
    int count = Sqflite.firstIntValue(await database.rawQuery(
            "select count(*) from Videos_Series inner join Videos on Videos_Series.Titre=Videos.Titre where date(Videos.Date_Parution)>=date('now','-1 year') and date(Videos.Date_Parution)<=date('now')")) ??
        0;
    //DataInitialize.closeConnection();
    return count;
  }

  static getListOfMetaDataOnVideo() {}

  static MetaData getMetaDataOnVideo() {
    return MetaData(nameField: "", typeField: "");
  }

  static getNamesOfTables() {}

  static getMetaData() {}
}
