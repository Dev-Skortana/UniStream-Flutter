import 'package:collection/collection.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Helpers/Use_Dictionnary_FullTypeVideo_ListServiceManager.dart';
import 'package:unistream/Helpers/Use_Dictionnary_ServiceManager_BaseModel.dart';
import 'package:unistream/Models/Ajout_Oeuvre.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';
import 'package:unistream/Services/Databases/Video_Manager.dart';

/// Écrit une œuvre dans la bibliothèque avec le chemin d'insertion de l'écran « Enregistrements » :
/// les deux dictionnaires (type complet → managers, manager → modèle) et les *_Manager existants.
///
/// Différence voulue avec ViewmodelEnregistrement.startRecording : chaque insertion est ATTENDUE, dans l'ordre
/// du dictionnaire (Genres, Pays… avant Videos, Videos avant les tables qui la référencent). Là-bas, les
/// insertions sont lancées sans être attendues : une erreur passe inaperçue et la fin est annoncée trop tôt.
class AjoutOeuvreManager {
  Future<Database> get _db => DataInitialize.getDatabase();

  Future<bool> titreExiste(String titre) async =>
      (await (await _db).rawQuery('SELECT 1 FROM Videos WHERE Titre=? LIMIT 1', [titre])).isNotEmpty;

  /// Œuvres reliées, versions suivies et titres présents : de quoi classer les résultats de recherche.
  Future<EtatBibliotheque> etatBibliotheque() async {
    final db = await _db;
    final liens = await db.rawQuery('SELECT Id_Oeuvre, Cle_Fiche FROM Oeuvres_Liens');
    final titres = await db.rawQuery('SELECT Titre FROM Videos');
    return EtatBibliotheque(
      oeuvres: {for (final l in liens) if (l['Id_Oeuvre'] != null) (l['Id_Oeuvre'] as num).toInt()},
      cles: {for (final l in liens) if (l['Cle_Fiche'] != null) l['Cle_Fiche'] as String},
      titres: {for (final t in titres) t['Titre'] as String},
    );
  }

  /// Renvoie la liste des tables qui ont refusé l'écriture (vide = tout est passé).
  Future<List<String>> enregistrer(RegisterData data) async {
    final managers =
        UseDictionnaryFulltypevideoListservicemanager().DictionnaryFullTypeVideoListServiceManager[data.fullType_Video.name]!;
    final modeles = UseDictionnaryServicemanagerBasemodel(data).DictionnaryServiceManagerBaseModel;
    final refus = <String>[];
    for (final paire in IterableZip<dynamic>([managers['Types'] as List, managers['Instances'] as List])) {
      final Type type = paire[0];
      final IloadManagerDatabase manager = paire[1]();
      final contenu = modeles[type];
      if (contenu == null) continue;
      for (final BaseModel modele in (contenu is List ? contenu : [contenu])) {
        if (!await manager.insert(modele)) refus.add('$type');
      }
      // Videos est la table mère : si elle échoue, inutile d'écrire les tables qui la référencent.
      if (manager is VideoManager && refus.isNotEmpty) break;
    }
    return refus;
  }
}
