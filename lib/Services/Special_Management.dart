import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Meta_Data.dart';

class SpecialManagement {
  static Stream<Map<String, dynamic>> getVideosOnTheLastTwelveMonths() async* {
    const String chaine_condition =
        "where date(Videos.Date_Parution)>=date('now','-1 year') and date(Videos.Date_Parution)<=date('now')";
    const String chaine_order = "order by Videos.Titre asc";
    Stream<Map<String, dynamic>> generator_videos_films =
        SpecialManagement.getVideosFilmsOnTheLastTwelveMonths(
            chaine_condition, chaine_order);
    Stream<Map<String, dynamic>> generator_videos_series =
        SpecialManagement.getVideosSeriesOnTheLastTwelveMonths(
            chaine_condition, chaine_order);
    yield* generator_videos_films;
    yield* generator_videos_series;
  }

  static Stream<Map<String, dynamic>> getVideosFilmsOnTheLastTwelveMonths(
      String chaine_condition, String chaine_order) async* {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> Records_films = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Videos_Films inner join Videos on Videos_Films.Titre=Videos.Titre ${chaine_condition} ${chaine_order}");
    DataInitialize.closeConnection();
    int iteration = 0;
    while (iteration < Records_films.length) {
      yield {
        "Titre": Records_films[iteration]["Titre"],
        "Description": Records_films[iteration]["Description"],
        "Duree": Records_films[iteration]["Duree"],
        "Date_Parution": Records_films[iteration]["Date_Parution"],
        "Lien_Affiche": Records_films[iteration]["Lien_Affiche"]
      };
      iteration += 1;
    }
  }

  static Stream<Map<String, dynamic>> getVideosSeriesOnTheLastTwelveMonths(
      String chaine_condition, String chaine_order) async* {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> Records_series = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche,Videos_Series.Titre Titre_Serie from Videos_Series inner join Videos on Videos_Series.Titre=Videos.Titre ${chaine_condition} ${chaine_order}");
    DataInitialize.closeConnection();
    int iteration = 0;
    while (iteration < Records_series.length) {
      yield {
        "Titre": Records_series[iteration]["Titre"],
        "Description": Records_series[iteration]["Description"],
        "Duree": Records_series[iteration]["Duree"],
        "Date_Parution": Records_series[iteration]["Date_Parution"],
        "Lien_Affiche": Records_series[iteration]["Lien_Affiche"],
        "Titre_Serie": Records_series[iteration]["Titre_Serie"]
      };
      iteration += 1;
    }
  }

  static Future<int> getTotalVideosFilmsOnTheLastTwelveMonths() async {
    Database database = await DataInitialize.getDatabase();
    int count = Sqflite.firstIntValue(await database.rawQuery(
            "select count(*) from Videos_Films inner join Videos on Videos_Films.Titre=Videos.Titre where date(Videos.Date_Parution)>=date('now','-1 year') and date(Videos.Date_Parution)<=date('now')")) ??
        0;
    DataInitialize.closeConnection();
    return count;
  }

  static Future<int> getTotalVideosSeriesOnTheLastTwelveMonths() async {
    Database database = await DataInitialize.getDatabase();
    int count = Sqflite.firstIntValue(await database.rawQuery(
            "select count(*) from Videos_Series inner join Videos on Videos_Series.Titre=Videos.Titre where date(Videos.Date_Parution)>=date('now','-1 year') and date(Videos.Date_Parution)<=date('now')")) ??
        0;
    DataInitialize.closeConnection();
    return count;
  }

  static getListOfMetaDataOnVideo() {}

  static MetaData getMetaDataOnVideo() {
    return MetaData(nameField: "", typeField: "");
  }

  static getNamesOfTables() {}

  static getMetaData() {}
}
