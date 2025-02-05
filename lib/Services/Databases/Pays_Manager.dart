import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Pays.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';

class PaysManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) {
    // TODO: implement GetGen
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> Records = await database.rawQuery(
        "select Pays.Nom from Pays inner join Videos on Pays.Titre=Videos.Titre where Videos.Titre=",
        [fields["Titre"]]);
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
        "select Pays.Nom from Pays where Pays.Nom={:Nom}", [fields["Nom"]]))[0];
    return Pays(nom: record["Nom"]);
  }

  @override
  Future<void> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "insert or ignore into Pays(Nom) values(?)", [(model as Pays).nom]);
  }
}
