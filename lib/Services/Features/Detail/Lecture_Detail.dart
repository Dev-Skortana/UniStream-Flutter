import 'package:sqflite/sqflite.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Services/Features/Detail/Infos_Detail.dart';

/// Lit en base les métadonnées d'UNE œuvre (par son titre).
///
/// Les anciens ViewModels chargeaient toutes les lignes de Videos_Genres,
/// Videos_Pays, etc. puis filtraient en mémoire ; ici, une requête ciblée
/// par table.
class LectureDetail {
  static Future<InfosDetail> lire(String titre, {required bool estSerie}) async {
    final Database base = await DataInitialize.getDatabase();

    Future<List<String>> noms(String table) async {
      final lignes = await base.rawQuery(
          'select Nom from $table where Titre = ?', [titre]);
      return InfosDetail.nettoyerNoms(lignes.map((l) => l['Nom']));
    }

    final resultats = await Future.wait([
      noms('Videos_Genres'),
      noms('Videos_Pays'),
      noms('Videos_Realisateurs'),
    ]);

    var episodes = const <int, List<int>>{};
    if (estSerie) {
      final lignes = await base.rawQuery(
          'select Saison, Episode from Details_Videos_Series where Titre = ?',
          [titre]);
      episodes = InfosDetail.rangerEpisodes(
          lignes.map((l) => (l['Saison'], l['Episode'])));
    }

    return InfosDetail(
      genres: resultats[0],
      pays: resultats[1],
      realisateurs: resultats[2],
      episodesParSaison: episodes,
    );
  }
}
