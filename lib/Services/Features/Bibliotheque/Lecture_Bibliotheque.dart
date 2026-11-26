import 'package:flutter/foundation.dart';
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

    Future<List<OeuvreBibliotheque>> lire(String nom, IloadManagerDatabase manager,
        FamilleOeuvre famille, FormatOeuvre format) async {
      try {
        final lignes = await manager.getList({});
        // GetGen attend la liste enveloppée : il lit item[0].
        return [
          for (final element in manager.GetGen([lignes]))
            OeuvreBibliotheque(
                video: element["Video"] as Video, famille: famille, format: format)
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
}
