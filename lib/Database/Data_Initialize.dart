import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

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
    _database = await DataInitialize._initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path_database =
        join(await getDatabasesPath(), "Database_UniStream.db");
    return await openDatabase(
      path_database,
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        await DataInitialize._createTables(db);
      },
      onOpen: (db) async {
        await DataInitialize._insertDatas(db);
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Videos(Titre varchar(100) primary KEY,Description TEXT,Duree time,Date_Parution date,Lien_Affiche varchar(170))");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Videos_Films(Titre varchar(100) PRIMARY KEY,foreign KEY(Titre) REFERENCES Videos(Titre) On DELETE CASCADE)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Videos_Series (Titre	varchar(100),PRIMARY KEY(Titre),FOREIGN KEY(Titre) REFERENCES Videos(Titre)  On DELETE CASCADE)");
    await db.execute(
        " CREATE TABLE IF NOT EXISTS Details_Videos_Series(Titre varchar(100),Saison INTEGER,Episode INTEGER,PRIMARY KEY(Titre,Saison,Episode),FOREIGN KEY(Titre) REFERENCES Videos_Series(Titre) On DELETE CASCADE)");
    await db.execute(
        " CREATE TABLE IF NOT EXISTS Animes_Series(Titre varchar(100) primary KEY,Studio varchar(30),foreign KEY(Titre) REFERENCES Videos_Series(Titre) On DELETE CASCADE)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Animes_Films (Titre	varchar(100),Studio	varchar(30),FOREIGN KEY(Titre) REFERENCES Videos_Films(Titre) On DELETE CASCADE,PRIMARY KEY(Titre)) ");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Dramas_Films (Titre	varchar(100),PRIMARY KEY(Titre),FOREIGN KEY(Titre) REFERENCES Videos_Films(Titre)  On DELETE CASCADE) ");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Dramas_Series(Titre varchar(100) PRIMARY KEY,FOREIGN KEY(Titre) REFERENCES Videos_Series(Titre) On DELETE CASCADE)");
    await db.execute(
        " CREATE TABLE IF NOT EXISTS Films(Titre varchar(100) primary KEY,FOREIGN KEY(Titre) REFERENCES Videos_Films(Titre) On DELETE CASCADE)");
    await db.execute(
        " CREATE TABLE IF NOT EXISTS Series(Titre varchar(100) primary KEY,foreign KEY(Titre) REFERENCES Videos_Series(Titre) On DELETE CASCADE)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Genres(Nom varchar(50) primary KEY)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Pays(Nom varchar(50) primary KEY)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Realisateurs(Nom varchar(50) primary KEY)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Videos_Genres(Titre varchar(100),Nom varchar(50),primary KEY(Titre,Nom),foreign KEY(Titre) REFERENCES Videos(Titre) On DELETE CASCADE,FOREIGN KEY(Nom) REFERENCES Genres(Nom) On DELETE CASCADE)");
    await db.execute(
        "CREATE TABLE IF NOT EXISTS Videos_Pays(Titre varchar(100),Nom varchar(50),primary KEY(Titre,Nom),FOREIGN KEY(Titre) REFERENCES Videos(Titre) On DELETE CASCADE,FOREIGN KEY(Nom) REFERENCES Pays(Nom) On DELETE CASCADE)");
    await db.execute(
        " CREATE TABLE IF NOT EXISTS Videos_Realisateurs(Titre varchar(100),Nom varchar(50),primary KEY(Titre,Nom),foreign KEY(Titre) REFERENCES Videos(Titre) On DELETE CASCADE,FOREIGN KEY(Nom) REFERENCES Realisateurs(Nom) On DELETE CASCADE)");
  }

  static Future<void> _insertDatas(Database db) async {
    await db.execute(
        "insert or ignore into Videos(Titre,Lien_Affiche) values(?,?)", [
      "Z",
      "assets/images/video_posters/1539165262_flcl-saison-2-progressive-vostfr.jpg"
    ]);
    await db
        .execute("insert or ignore into Videos_Series(Titre) values(?)", ["Z"]);

    await db.execute(
        "insert or ignore into Videos(Titre,Lien_Affiche) values(?,?)",
        ["B", "assets/images/video_posters/1586273590_shadowverse_vostfr.jpg"]);
    await db
        .execute("insert or ignore into Videos_Films(Titre) values(?)", ["B"]);

    await db.execute(
        "insert or ignore into Videos(Titre,Lien_Affiche) values(?,?)", [
      "C",
      "assets/images/video_posters/1539165262_flcl-saison-2-progressive-vostfr.jpg"
    ]);
    await db
        .execute("insert or ignore into Videos_Series(Titre) values(?)", ["C"]);
    await db.execute(
        "insert or ignore into Videos(Titre,Lien_Affiche) values(?,?)", [
      "e",
      "assets/images/video_posters/1539165262_flcl-saison-2-progressive-vostfr.jpg"
    ]);
    await db
        .execute("insert or ignore into Videos_Series(Titre) values(?)", ["e"]);

    await db.execute(
        "insert or ignore into Videos(Titre,Lien_Affiche) values(?,?)",
        ["g", "assets/images/video_posters/kuzu-no-honkai.jpg"]);
    await db
        .execute("insert or ignore into Videos_Series(Titre) values(?)", ["g"]);

    await db.execute(
        "insert or ignore into Videos(Titre,Lien_Affiche) values(?,?)",
        ["X", "assets/images/video_posters/kuzu-no-honkai.jpg"]);
    await db
        .execute("insert or ignore into Videos_Series(Titre) values(?)", ["X"]);
  }

  static void closeConnection() async {
    await DataInitialize._database!.close();
  }
}
