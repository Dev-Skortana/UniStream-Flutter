import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Anime_Serie.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Services/Interface/ILoad_Manager_Database.dart';

class AnimeSerieManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) {
    // TODO: implement GetGen
    throw UnimplementedError();
  }

  @override
  Future<List<BaseModel>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> records_animes_series = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche,Animes_Series.Studio from Animes_Series inner join Videos_Series on Animes_Series.Titre=Videos_Series.Titre inner join Videos on Animes_Series.Titre=Videos.Titre");
    DataInitialize.closeConnection();
    List<BaseModel> results = [];
    return results;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<bool> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "insert or ignore into Animes_Series(Titre,Studio) values(?,?)",
        [(model as AnimeSerie).titre, (model as AnimeSerie).studio]);
    return true;
  }
}
