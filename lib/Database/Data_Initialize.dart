import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';

class DataInitialize {
  static Database? _database;

  static Database? get database => _database;
  static void set database(value) {
    _database = value;
  }

  static Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }
    _database = await DataInitialize.initDB();

    return _database!;
  }

  static Future<Database> initDB() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final appDocumentsDir =
          await ManagerOfLocationFolderFileOfApp.getFolderDatabase();
      final dbPath = join(appDocumentsDir.path, "Database_UniStream.db");
      final winLinuxDB = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(onConfigure: (db) async {
          await DataInitialize._configureDatabase(db);
        }),
      );
      return winLinuxDB;
    } else if (Platform.isAndroid || Platform.isIOS) {
      final documentsDirectory =
          await ManagerOfLocationFolderFileOfApp.getFolderDatabase();
      final path = join(documentsDirectory.path, "Database_UniStream.db");
      final iOSAndroidDB = await openDatabase(path, onConfigure: (db) async {
        await DataInitialize._configureDatabase(db);
      });
      return iOSAndroidDB;
    }
    throw Exception("Unsupported platform");
  }

  static FutureOr<void> _configureDatabase(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  static void closeConnection() async {
    await DataInitialize._database!.close();
  }
}
