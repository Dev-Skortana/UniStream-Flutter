import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';

class RebootDatabaseManager {
  RebootDatabaseManager();

  Future<void> reboot() async {
    Database database = await DataInitialize.getDatabase();
    await database.rawDelete("delete from Videos");
    await database.rawDelete("delete from Genres");
    await database.rawDelete("delete from Pays");
    await database.rawDelete("delete from Realisateurs");
    //DataInitialize.closeConnection();
  }
}
