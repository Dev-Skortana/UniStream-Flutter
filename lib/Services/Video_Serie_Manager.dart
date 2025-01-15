import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video_Serie.dart';
import 'package:unistream/Services/Interface/ILoad_Manager_Database.dart';

class VideoSerieManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) {
    // TODO: implement GetGen
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> Records = await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Videos_Series inner join Videos on Videos_Series.Titre=Videos.Titre");
    //DataInitialize.closeConnection();

    return Records;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    Map<String, dynamic> record_video_serie = (await database.rawQuery(
        "select Videos.Titre,Videos.Description,Videos.Duree,date(Videos.Date_Parution) Date_Parution,Videos.Lien_Affiche from Videos_Series inner join Videos on Videos_Series.Titre=Videos.Titre where Videos_Series.Titre=?",
        [fields["Titre"]]))[0];
    return BaseModel();
  }

  @override
  Future<void> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "insert or ignore into Videos_Series(Titre) values(?)",
        [(model as VideoSerie).titre]);
  }
}
