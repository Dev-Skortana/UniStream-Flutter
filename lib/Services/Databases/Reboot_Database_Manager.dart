import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';

class RebootDatabaseManager {
  RebootDatabaseManager();

  void reboot() async {
    Database database = await DataInitialize.getDatabase();
    database.rawDelete("delete from Videos");
    database.rawDelete("delete from Genres");
    database.rawDelete("delete from Pays");
    database.rawDelete("delete from Realisateurs");
    DataInitialize.closeConnection();
  }
}
