import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Drama_Film.dart';
import 'package:unistream/Models/Drama_Serie.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Models/Video_Serie.dart';
import 'package:unistream/Services/Interface/ILoad_Manager_Database.dart';

class DramaSerieManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) {
    // TODO: implement GetGen
    throw UnimplementedError();
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
  Future<void> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "insert or ignore into Dramas_Series(Titre) values(?)",
        [(model as DramaFilm).titre]);
  }
}
