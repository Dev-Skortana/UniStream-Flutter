import 'dart:async';

import 'package:collection/collection.dart';

import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Models_MetaData/Meta_Data.dart';
import 'dart:typed_data';

class SpecialManagement {
  static Future<Iterator<Map<String, dynamic>>>
      getVideosOnTheLastTwelveMonths() async {
    const String chaine_condition =
        "where date(Videos.Date_Parution)>=date('now','-1 year') and date(Videos.Date_Parution)<=date('now')";
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

  static Future<List<MetaData>> getListOfMetaDataOnVideo(
      String name_table) async {
    Database database = await DataInitialize.getDatabase();
    var records = await database
        .rawQuery("select name,type from PRAGMA_Table_Info('${name_table}')");
    return records
        .map((record) => MetaData(
            nameField: record["name"].toString(),
            typeField: record["type"].toString()))
        .cast<MetaData>()
        .toList();
  }

  static Future<MetaData> getMetaDataOnVideo(String name_field) async {
    List<String> names_tables = await SpecialManagement._getNamesOfTables();
    MetaData meta_data;
    for (String name_table in names_tables) {
      meta_data = await SpecialManagement._getMetaData(
          name_table: name_table, name_field: name_field);
      if (meta_data.nameField.isNotEmpty && meta_data.typeField.isNotEmpty) {
        return meta_data;
      }
    }
    return MetaData(nameField: "", typeField: "");
  }

  static Future<List<String>> _getNamesOfTables() async {
    Database database = await DataInitialize.getDatabase();
    final List<Map<String, dynamic>> records = await database
        .rawQuery("SELECT name from sqlite_master WHERE type = 'table'");
    return records.map((record) => record["name"]).cast<String>().toList();
  }

  static Future<MetaData> _getMetaData(
      {required String name_table, required String name_field}) async {
    Database database = await DataInitialize.getDatabase();
    String requete_part_condition =
        "upper(replace(name,'_',''))='${name_field.toUpperCase()}'";
    if (["Genres", "Realisateurs", "Pays"].contains(name_table)) {
      final String name_field_transform =
          name_field.replaceAll(name_field, "Nom${name_field}");
      requete_part_condition =
          "upper(replace(replace(name,'_','') , replace(name,'_','') , replace(name,'_','') || '$name_table'))='${name_field_transform.toUpperCase()}'";
    }
    var record = (await database.rawQuery(
            "select name,type from PRAGMA_Table_Info('${name_table}') where ${requete_part_condition}"))
        .firstOrNull;
    if (record != null) {
      return MetaData(
          nameField: record["name"].toString(),
          typeField: record["type"].toString());
    }
    return MetaData(nameField: "", typeField: "");
  }
}
