import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Genre.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Services/Interface/ILoad_Manager_Database.dart';

class GenreManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) {
    // TODO: implement GetGen
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> Records = await database.rawQuery(
        "select Genres.Nom from Genres inner join Videos on Genres.Titre=Videos.Titre where Videos.Titre=");
    //DataInitialize.closeConnection();
    List<Map<String, dynamic>> genres = [];
    for (var record_genre in Records) {
      genres.add({"nom": record_genre[0]});
    }
    return genres;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    Map<String, dynamic> record = (await database.rawQuery(
        "select Genres.Nom from Genres where Genres.Nom={:Nom}",
        [fields["Nom"]]))[0];
    return Genre(nom: record["Nom"]);
  }

  @override
  Future<void> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "insert or ignore into Genres(Nom) values(?)", [(model as Genre).nom]);
  }
}
