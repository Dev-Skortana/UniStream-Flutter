import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Services/Features/Detail/Infos_Detail.dart';
import 'package:unistream/Services/Features/Historique/Suivi_Visionnage.dart';

/// Accès à la table Historique_Visionnage (migrations 2 et 3).
class HistoriqueManager {
  static const String _inserer = 'INSERT OR REPLACE INTO Historique_Visionnage'
      '(Titre, Saison, Episode, Vu_Le, Episodes_Connus, Site) VALUES (?, ?, ?, ?, ?, ?)';

  /// Enregistre (ou rafraîchit) la lecture d'un épisode, ou d'un film
  /// avec saison = episode = 0. [site] : source utilisée (null si marqué
  /// « vu » à la main).
  ///
  /// INSERT OR REPLACE plutôt qu'un UPSERT (ON CONFLICT … DO UPDATE) :
  /// le SQLite des Android antérieurs à 11 ne connaît pas l'UPSERT.
  Future<void> enregistrer(
      {required String titre,
      int saison = 0,
      int episode = 0,
      int episodesConnus = 0,
      String? site}) async {
    final base = await DataInitialize.getDatabase();
    await base.rawInsert(_inserer, [
      titre, saison, episode, DateTime.now().toIso8601String(), episodesConnus, site
    ]);
  }

  /// Marque plusieurs épisodes « vus » d'un coup, dans l'ordre donné : chacun
  /// reçoit une date un peu plus récente que le précédent, pour que le
  /// dernier de la liste soit bien le « dernier lu » (reprise juste après).
  Future<void> marquerVus(
      {required String titre,
      required List<(int, int)> episodes,
      int episodesConnus = 0}) async {
    if (episodes.isEmpty) return;
    final base = await DataInitialize.getDatabase();
    final debut = DateTime.now();
    await base.transaction((txn) async {
      for (var i = 0; i < episodes.length; i++) {
        final (s, e) = episodes[i];
        final date = debut.add(Duration(milliseconds: i)).toIso8601String();
        await txn.rawInsert(_inserer, [titre, s, e, date, episodesConnus, null]);
      }
    });
  }

  /// Retire un épisode de l'historique (« non vu »).
  Future<void> retirer(
      {required String titre, required int saison, required int episode}) async {
    final base = await DataInitialize.getDatabase();
    await base.rawDelete(
        'DELETE FROM Historique_Visionnage WHERE Titre = ? AND Saison = ? AND Episode = ?',
        [titre, saison, episode]);
  }

  /// Dernier site utilisé pour regarder cette œuvre (null si aucun).
  Future<String?> derniereSource(String titre) async {
    final base = await DataInitialize.getDatabase();
    final lignes = await base.rawQuery(
        'SELECT Site FROM Historique_Visionnage '
        'WHERE Titre = ? AND Site IS NOT NULL ORDER BY Vu_Le DESC LIMIT 1',
        [titre]);
    return lignes.isEmpty ? null : lignes.first['Site'] as String?;
  }

  /// Tout l'historique, ou celui d'une seule œuvre.
  Future<List<EntreeHistorique>> lire({String? titre}) async {
    final base = await DataInitialize.getDatabase();
    final lignes = await base.rawQuery(
      'SELECT Titre, Saison, Episode, Vu_Le, Episodes_Connus '
      'FROM Historique_Visionnage${titre == null ? '' : ' WHERE Titre = ?'}',
      titre == null ? null : [titre],
    );
    return [
      for (final l in lignes)
        if (DateTime.tryParse('${l['Vu_Le']}') case final vuLe?)
          EntreeHistorique(
            titre: l['Titre'] as String,
            saison: int.tryParse('${l['Saison']}') ?? 0,
            episode: int.tryParse('${l['Episode']}') ?? 0,
            vuLe: vuLe,
            episodesConnus: int.tryParse('${l['Episodes_Connus']}') ?? 0,
          ),
    ];
  }

  /// Épisodes (saison → épisodes) des séries présentes dans l'historique,
  /// en une requête.
  Future<Map<String, Map<int, List<int>>>> episodesDesOeuvresSuivies() async {
    final base = await DataInitialize.getDatabase();
    final lignes = await base.rawQuery(
        'SELECT Titre, Saison, Episode FROM Details_Videos_Series '
        'WHERE Titre IN (SELECT DISTINCT Titre FROM Historique_Visionnage)');
    final parTitre = <String, List<(Object?, Object?)>>{};
    for (final l in lignes) {
      parTitre
          .putIfAbsent(l['Titre'] as String, () => [])
          .add((l['Saison'], l['Episode']));
    }
    return parTitre
        .map((titre, eps) => MapEntry(titre, InfosDetail.rangerEpisodes(eps)));
  }

  /// Suivi de toutes les œuvres déjà regardées (vide si la table manque
  /// ou est illisible : l'historique ne doit jamais bloquer un écran).
  Future<Map<String, SuiviOeuvre>> suivis() async {
    try {
      final resultats =
          await Future.wait([lire(), episodesDesOeuvresSuivies()]);
      return SuiviVisionnage.calculer(
          resultats[0] as List<EntreeHistorique>,
          resultats[1] as Map<String, Map<int, List<int>>>);
    } catch (_) {
      return const {};
    }
  }
}
