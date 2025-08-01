import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Models/Video_Realisateur.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';

class VideoRealisateurManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) sync* {
    Iterator iterator_source_videosrealisateurs = item.iterator;
    int iteration = 0;
    while (iterator_source_videosrealisateurs.moveNext()) {
      yield {
        "index": iteration,
        "Video": VideoRealisateur.parseToVideoRealisateur(
          titre: iterator_source_videosrealisateurs.current["Titre"],
          nom: iterator_source_videosrealisateurs.current["Nom"],
        )
      };
      iteration += 1;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<Map<String, dynamic>> records_animes_series = await database.rawQuery(
        "select Videos_Realisateurs.Titre,Videos_Realisateurs.Nom from Videos_Realisateurs");
    //DataInitialize.closeConnection();

    return records_animes_series;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<bool> insert(BaseModel model) async {
    try {
      Database database = await DataInitialize.getDatabase();
      await database.execute(
          "insert or ignore into Videos_Realisateurs(Titre,Nom) values(?,?)",
          [(model as VideoRealisateur).titre, (model as VideoRealisateur).nom]);
    } on DatabaseException catch (exception_database) {
      return false;
    } finally {}
    return true;
  }
}
