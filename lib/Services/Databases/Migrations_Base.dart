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
    if (version < 2) {
      await db.transaction((txn) async {
        // Historique de visionnage : une ligne par épisode lancé (Saison et
        // Episode à 0 pour un film), la plus récente date de lecture gardée.
        // Episodes_Connus = nombre d'épisodes de la série au moment de la
        // lecture : s'il y en a plus aujourd'hui, de nouveaux sont arrivés.
        // ON DELETE CASCADE : réinitialiser la bibliothèque vide l'historique.
        await txn.execute('''
          CREATE TABLE IF NOT EXISTS Historique_Visionnage (
            Titre            TEXT NOT NULL REFERENCES Videos(Titre) ON DELETE CASCADE ON UPDATE CASCADE,
            Saison           INTEGER NOT NULL DEFAULT 0,
            Episode          INTEGER NOT NULL DEFAULT 0,
            Vu_Le            TEXT NOT NULL,
            Episodes_Connus  INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (Titre, Saison, Episode)
          )''');
        await txn.execute(
            'CREATE INDEX IF NOT EXISTS Historique_Vu_Le ON Historique_Visionnage(Vu_Le)');
        await txn.execute('PRAGMA user_version = 2');
      });
    }
  }
}
