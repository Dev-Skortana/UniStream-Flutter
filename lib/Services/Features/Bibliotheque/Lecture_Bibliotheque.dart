import 'package:flutter/foundation.dart';
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Services/Databases/Anime_Film_Manager.dart';
import 'package:unistream/Services/Databases/Anime_Serie_Manager.dart';
import 'package:unistream/Services/Databases/Drama_Film_Manager.dart';
import 'package:unistream/Services/Databases/Drama_Serie_Manager.dart';
import 'package:unistream/Services/Databases/Film_Manager.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';
import 'package:unistream/Services/Databases/Serie_Manager.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';

/// Résultat d'une lecture de la bibliothèque : les œuvres lues et les
/// catégories qui n'ont pas pu l'être (affichées à l'utilisateur).
class ContenuBibliotheque {
  final List<OeuvreBibliotheque> oeuvres;
  final List<String> echecs;
  const ContenuBibliotheque(this.oeuvres, this.echecs);
}

/// Lit toute la bibliothèque (6 tables) avec les managers existants.
/// Partagé par la Bibliothèque et l'Accueil.
class LectureBibliotheque {
  static Future<ContenuBibliotheque> toutes() async {
    final echecs = <String>[];
    final genresParTitre = await _genresParTitre(echecs);

    Future<List<OeuvreBibliotheque>> lire(String nom, IloadManagerDatabase manager,
        FamilleOeuvre famille, FormatOeuvre format) async {
      try {
        final lignes = await manager.getList({});
        // GetGen attend la liste enveloppée : il lit item[0].
        return [
          for (final element in manager.GetGen([lignes]))
            OeuvreBibliotheque(
                video: element["Video"] as Video,
                famille: famille,
                format: format,
                genres: genresParTitre[(element["Video"] as Video).titre] ??
                    const [])
        ];
      } catch (e) {
        debugPrint("[Bibliothèque] lecture « $nom » impossible : $e");
        echecs.add(nom);
        return const [];
      }
    }

    final parties = await Future.wait([
      lire('animes (séries)', AnimeSerieManager(), FamilleOeuvre.anime, FormatOeuvre.serie),
      lire('animes (films)', AnimeFilmManager(), FamilleOeuvre.anime, FormatOeuvre.film),
      lire('dramas (séries)', DramaSerieManager(), FamilleOeuvre.drama, FormatOeuvre.serie),
      lire('dramas (films)', DramaFilmManager(), FamilleOeuvre.drama, FormatOeuvre.film),
      lire('séries', SerieManager(), FamilleOeuvre.live, FormatOeuvre.serie),
      lire('films', FilmManager(), FamilleOeuvre.live, FormatOeuvre.film),
    ]);
    return ContenuBibliotheque(parties.expand((p) => p).toList(), echecs);
  }

  /// Tous les genres en une requête (une par œuvre serait N requêtes).
  static Future<Map<String, List<String>>> _genresParTitre(
      List<String> echecs) async {
    try {
      final base = await DataInitialize.getDatabase();
      final lignes =
          await base.rawQuery('select Titre, Nom from Videos_Genres');
      final resultat = <String, List<String>>{};
      for (final ligne in lignes) {
        final titre = ligne['Titre'] as String?;
        final nom = (ligne['Nom'] as String?)?.trim() ?? '';
        if (titre == null || nom.isEmpty) continue;
        resultat.putIfAbsent(titre, () => []).add(nom);
      }
      return resultat;
    } catch (e) {
      debugPrint("[Bibliothèque] lecture des genres impossible : $e");
      echecs.add('genres');
      return const {};
    }
  }
}
