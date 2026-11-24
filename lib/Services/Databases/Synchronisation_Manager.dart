import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';
import 'package:unistream/Models/Synchronisation.dart';

/// Écriture de la synchronisation dans la bibliothèque, et sauvegarde / restauration de la base.
class SynchronisationManager {
  static const String nomBase = 'Database_UniStream.db';
  static const int sauvegardesGardees = 5;

  Future<Directory> _dossierSauvegardes() async {
    final d = Directory(join((await ManagerOfLocationFolderFileOfApp.getFolderDatabase()).path, 'sauvegardes'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  /// Copie du fichier de la base AVANT toute écriture. Appelée hors transaction : sqflite (journal DELETE)
  /// n'a alors aucune écriture en cours, la copie est cohérente. (VACUUM INTO serait plus sûr, mais il exige
  /// SQLite 3.27, absent des Android < 11.)
  Future<String> sauvegarder() async {
    final source = File(join((await ManagerOfLocationFolderFileOfApp.getFolderDatabase()).path, nomBase));
    final horodatage = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final cible = join((await _dossierSauvegardes()).path, 'Database_UniStream_$horodatage.db');
    await source.copy(cible);
    final anciennes = await getSauvegardes();
    for (final f in anciennes.skip(sauvegardesGardees)) {
      await f.delete();
    }
    return cible;
  }

  /// Sauvegardes, de la plus récente à la plus ancienne.
  Future<List<File>> getSauvegardes() async {
    final fichiers = (await _dossierSauvegardes()).listSync().whereType<File>().where((f) => f.path.endsWith('.db')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    return fichiers;
  }

  /// Remet une sauvegarde en place. La connexion est fermée puis rouverte au prochain accès ;
  /// les écrans déjà chargés gardent les anciennes données jusqu'au redémarrage de l'appli.
  Future<void> restaurer(File sauvegarde) async {
    final db = await DataInitialize.getDatabase();
    await db.close();
    DataInitialize.database = null;
    final cible = File(join((await ManagerOfLocationFolderFileOfApp.getFolderDatabase()).path, nomBase));
    await sauvegarde.copy(cible.path);
  }

  /// Applique les changements d'UNE œuvre dans une transaction : tout ou rien pour cette œuvre.
  /// [cheminAffiche] : fichier déjà téléchargé (le téléchargement se fait avant, hors transaction).
  /// Retourne le nombre de changements écrits.
  Future<int> appliquer(EtatLocal local, List<Changement> changements, {String? cheminAffiche}) async {
    final db = await DataInitialize.getDatabase();
    var n = 0;
    await db.transaction((txn) async {
      for (final c in changements) {
        switch (c.type) {
          case TypeChangement.description:
            await txn.rawUpdate('UPDATE Videos SET Description=? WHERE Titre=?', [c.valeur, local.titre]);
            n++;
          case TypeChangement.duree:
            await txn.rawUpdate('UPDATE Videos SET Duree=time(?) WHERE Titre=?', [c.valeur, local.titre]);
            n++;
          case TypeChangement.annee:
            await txn.rawUpdate('UPDATE Videos SET Date_Parution=? WHERE Titre=?', [c.valeur, local.titre]);
            n++;
          case TypeChangement.affiche:
            if (cheminAffiche != null) {
              await txn.rawUpdate('UPDATE Videos SET Lien_Affiche=? WHERE Titre=?', [cheminAffiche, local.titre]);
              n++;
            }
          case TypeChangement.episodes:
          case TypeChangement.saison:
            n += await _ajouterEpisodes(txn, local, c.saison!, c.valeur as int);
        }
      }
    });
    return n;
  }

  /// Complète une saison jusqu'à [total] épisodes, en numérotant après le plus grand numéro déjà présent
  /// (les numéros existants ne sont jamais modifiés). Saison vide : on commence à 1, comme l'appli
  /// (292 séries sur 298) — ce numéro est aussi celui envoyé à la recherche du lien de lecture.
  Future<int> _ajouterEpisodes(Transaction txn, EtatLocal local, int saison, int total) async {
    final dejaLa = local.episodesParSaison[saison] ?? 0;
    if (total <= dejaLa) return 0;
    var numero = (local.dernierEpisodeParSaison[saison] ?? 0) + 1;
    for (var i = dejaLa; i < total; i++, numero++) {
      await txn.rawInsert('INSERT OR IGNORE INTO Details_Videos_Series(Titre, Saison, Episode) VALUES (?,?,?)',
          [local.titre, saison, numero]);
    }
    return 1;
  }
}
