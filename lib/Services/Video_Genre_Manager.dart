import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video_Genre.dart';
import 'package:unistream/Services/Interface/ILoad_Manager_Database.dart';

class VideoGenreManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) {
    // TODO: implement GetGen
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> records_videos_genres = await database.rawQuery(
        "select Videos_Genres.Titre,Videos_Genres.Nom from Videos_Genres");
    //DataInitialize.closeConnection();

    return records_videos_genres;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<void> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "insert or ignore into Videos_Genres(Titre,Nom) values(?,?)",
        [(model as VideoGenre).titre, (model as VideoGenre).nom]);
  }
}
