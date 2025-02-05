import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Realisateur.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';

class RealisateurManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) {
    // TODO: implement GetGen
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> Records = await database.rawQuery(
        "select Realisateurs.Nom from Realisateurs inner join Videos on Realisateurs.Titre=Videos.Titre where Videos.Titre=?",
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
        "select Realisateurs.Nom from Realisateurs where Realisateurs.Nom={:Nom}",
        [fields["Nom"]]))[0];
    return Realisateur(nom: record["Nom"]);
  }

  @override
  Future<void> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute("insert or ignore into Realisateurs(Nom) values(?)",
        [(model as Realisateur).nom]);
  }
}
