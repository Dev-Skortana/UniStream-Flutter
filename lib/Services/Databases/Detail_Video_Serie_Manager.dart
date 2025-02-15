import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Detail_Video_Serie.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';

class DetailVideoSerieManager implements IloadManagerDatabase {
  @override
  Iterable GetGen(item) sync* {
    Iterator iterator_source_detailsvideoserie = item.iterator;
    int iteration = 0;
    while (iterator_source_detailsvideoserie.moveNext()) {
      yield {
        "index": iteration,
        "Video": DetailVideoSerie.parseToDetailVideoSerie(
            titre_videoserie:
                iterator_source_detailsvideoserie.current["Titre"],
            saison: iterator_source_detailsvideoserie.current["Saison"],
            episode: iterator_source_detailsvideoserie.current["Episode"])
      };
      iteration += 1;
    }
    ();
  }

  @override
  Future<List<Map<String, dynamic>>> getList(Map<String, Object> fields) async {
    Database database = await DataInitialize.getDatabase();
    List<
        Map<String,
            dynamic>> records_details_videos_series = await database.rawQuery(
        "select Details_Videos_Series.Titre,Details_Videos_Series.Saison,Details_Videos_Series.Episode from Details_Videos_Series inner join Videos_Series on Details_Videos_Series.Titre=Videos_Series.Titre");
    //DataInitialize.closeConnection();

    return records_details_videos_series;
  }

  @override
  Future<BaseModel> getOne(Map<String, Object> fields) async {
    // TODO: implement getOne
    throw UnimplementedError();
  }

  @override
  Future<void> insert(BaseModel model) async {
    DetailVideoSerie detailserie = model as DetailVideoSerie;
    Database database = await DataInitialize.getDatabase();
    await database.execute(
        "insert or ignore into Details_Videos_Series(Titre,Saison,Episode) values(?,?,?)",
        [detailserie.titre, detailserie.saison, detailserie.episode]);
  }
}
