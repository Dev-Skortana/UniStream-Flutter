import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video_Pays.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';

class VideoPaysManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) sync* {
    Iterator iterator_source_videospays = item.iterator;
    int iteration = 0;
    while (iterator_source_videospays.moveNext()) {
      yield {
        "index": iteration,
        "Video": VideoPays.parseToVideoPays(
          titre: iterator_source_videospays.current["Titre"],
          nom: iterator_source_videospays.current["Nom"],
        )
      };
      iteration += 1;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> records_videos_pays = await database
        .rawQuery("select Videos_Pays.Titre,Videos_Pays.Nom from Videos_Pays");
    //DataInitialize.closeConnection();

    return records_videos_pays;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future<void> insert(BaseModel model) async {
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "insert or ignore into Videos_Pays(Titre,Nom) values(?,?)",
        [(model as VideoPays).titre, (model as VideoPays).nom]);
  }
}
