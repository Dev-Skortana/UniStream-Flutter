import 'package:sqflite/sqflite.dart';

/// Migrations de la base de l'appli, numérotées par PRAGMA user_version.
///
/// Pourquoi pas `openDatabase(version: …, onUpgrade: …)` : la base actuelle est en version 0 ;
/// sqflite appellerait alors onCreate (base « neuve ») sur une base déjà remplie.
class MigrationsBase {
  static Future<void> appliquer(Database db) async {
    final version = Sqflite.firstIntValue(await db.rawQuery('PRAGMA user_version')) ?? 0;
    if (version < 1) {
      await db.transaction((txn) async {
        // Lien titre de l'appli → œuvre de l'index du serveur (et version suivie).
        // Table à part : le code existant (Videos et ses tables) n'est pas touché.
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS Oeuvres_Liens (
            Titre      TEXT PRIMARY KEY REFERENCES Videos(Titre) ON DELETE CASCADE ON UPDATE CASCADE,
            Id_Oeuvre  INTEGER NOT NULL,
            Cle_Fiche  TEXT,
            Source     TEXT NOT NULL,          -- auto (rapprochement du serveur) | manuel (choix de l'utilisateur)
            Lie_Le     TEXT NOT NULL
          )''');
        await txn.execute('PRAGMA user_version = 1');
      });
    }
  }
}
