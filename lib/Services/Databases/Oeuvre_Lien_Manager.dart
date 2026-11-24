import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Synchronisation.dart';

/// Table Oeuvres_Liens (titre de l'appli → œuvre du serveur) et lecture de l'état local d'un titre.
/// N'écrit que dans Oeuvres_Liens ; la bibliothèque est écrite par SynchronisationManager.
class OeuvreLienManager {
  Future<Database> get _db => DataInitialize.getDatabase();

  /// Titres de l'appli au format de POST /v1/rapprocher.
  Future<List<Map<String, dynamic>>> getTitresPourRapprochement() async {
    final db = await _db;
    final familles = <String, Set<String>>{};
    for (final (table, famille) in [
      ('Animes_Series', 'Anime'),
      ('Animes_Films', 'Anime'),
      ('Dramas_Series', 'Drama'),
      ('Dramas_Films', 'Drama')
    ]) {
      for (final r in await db.rawQuery('SELECT Titre FROM $table')) {
        familles.putIfAbsent(r['Titre'] as String, () => {}).add(famille);
      }
    }
    final films = {for (final r in await db.rawQuery('SELECT Titre FROM Videos_Films')) r['Titre'] as String};
    final videos = await db.rawQuery('SELECT Titre, Lien_Affiche FROM Videos ORDER BY Titre');
    return [
      for (final v in videos)
        {
          'titre': v['Titre'],
          'familles': (familles[v['Titre']] ?? <String>{}).toList(),
          'categorie': films.contains(v['Titre']) ? 'Film' : 'Serie',
          'affiche': v['Lien_Affiche'],
        }
    ];
  }

  /// Liens sûrs du serveur. Un lien choisi à la main (Source = manuel) n'est jamais remplacé.
  /// (INSERT OR IGNORE + UPDATE plutôt qu'un UPSERT : le SQLite des Android < 11 ne connaît pas ON CONFLICT DO UPDATE.)
  Future<int> insertLiensSurs(List<dynamic> sures) async {
    final db = await _db;
    final maintenant = DateTime.now().toUtc().toIso8601String();
    await db.transaction((txn) async {
      for (final s in sures) {
        final cle = (s['fiche'] as Map?)?['cle'];
        await txn.rawInsert(
            "INSERT OR IGNORE INTO Oeuvres_Liens (Titre, Id_Oeuvre, Cle_Fiche, Source, Lie_Le) VALUES (?,?,?,'auto',?)",
            [s['titre'], s['id_oeuvre'], cle, maintenant]);
        await txn.rawUpdate(
            "UPDATE Oeuvres_Liens SET Id_Oeuvre=?, Cle_Fiche=?, Lie_Le=? WHERE Titre=? AND Source='auto'",
            [s['id_oeuvre'], cle, maintenant, s['titre']]);
      }
    });
    return sures.length;
  }

  /// Œuvre fusionnée côté serveur : l'identifiant renvoyé par /v1/sync remplace l'ancien.
  Future<void> updateIdOeuvre(String titre, int idOeuvre) async =>
      (await _db).rawUpdate('UPDATE Oeuvres_Liens SET Id_Oeuvre=? WHERE Titre=?', [idOeuvre, titre]);

  Future<List<Map<String, Object?>>> getList() async =>
      (await _db).rawQuery('SELECT Titre, Id_Oeuvre, Cle_Fiche, Source FROM Oeuvres_Liens ORDER BY Titre');

  Future<int> countTitres() async =>
      Sqflite.firstIntValue(await (await _db).rawQuery('SELECT COUNT(*) FROM Videos')) ?? 0;

  Future<EtatLocal> getEtatLocal(String titre) async {
    final db = await _db;
    final v = await db.rawQuery(
        'SELECT Titre, Description, Duree, date(Date_Parution) Date_Parution, Lien_Affiche FROM Videos WHERE Titre=?',
        [titre]);
    final saisons = await db.rawQuery(
        'SELECT Saison, COUNT(*) n, MAX(Episode) dernier FROM Details_Videos_Series WHERE Titre=? GROUP BY Saison',
        [titre]);
    final serie = await db.rawQuery('SELECT 1 FROM Videos_Series WHERE Titre=?', [titre]);
    final r = v.isEmpty ? const <String, Object?>{} : v.first;
    final affiche = r['Lien_Affiche'] as String?;
    return EtatLocal(
      titre: titre,
      description: r['Description'] as String?,
      duree: r['Duree'] as String?,
      dateParution: r['Date_Parution'] as String?,
      lienAffiche: affiche,
      afficheExiste: affiche != null && affiche.isNotEmpty && !affiche.contains('visuals-NotFound') && File(affiche).existsSync(),
      estSerie: serie.isNotEmpty,
      episodesParSaison: {for (final s in saisons) (s['Saison'] as int): (s['n'] as int)},
      dernierEpisodeParSaison: {for (final s in saisons) (s['Saison'] as int): (s['dernier'] as int)},
    );
  }
}
