import 'package:flutter/foundation.dart';
import 'package:unistream/Models/Video.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/ViewModels/ViewModel_AnimeFilm.dart';
import 'package:unistream/ViewModels/ViewModel_AnimeSerie.dart';
import 'package:unistream/ViewModels/ViewModel_DramaFilm.dart';
import 'package:unistream/ViewModels/ViewModel_DramaSerie.dart';
import 'package:unistream/ViewModels/ViewModel_Film.dart';
import 'package:unistream/ViewModels/ViewModel_Serie.dart';

/// Toute la bibliothèque (animes, dramas, séries, films) dans une seule liste
/// filtrable, à la place des 4 onglets qui montraient une œuvre à la fois.
///
/// Même modèle que ViewModel_Synchronisation / ViewModel_Ajout_Oeuvre :
/// l'état est exposé en ValueNotifier, la vue écoute et appelle les méthodes.
/// Les lectures en base réutilisent les méthodes statiques des 6 ViewModels
/// existants : aucune nouvelle requête SQL.
class ViewmodelBibliotheque {
  final ValueNotifier<bool> chargement = ValueNotifier(true);

  /// Message à afficher si une partie de la bibliothèque n'a pas pu être lue.
  final ValueNotifier<String?> erreur = ValueNotifier(null);
  final ValueNotifier<FiltreBibliotheque> filtre =
      ValueNotifier(const FiltreBibliotheque());

  /// Œuvres après filtre et tri : ce que la grille affiche.
  final ValueNotifier<List<OeuvreBibliotheque>> oeuvres = ValueNotifier(const []);

  List<OeuvreBibliotheque> _toutes = const [];
  int get total => _toutes.length;

  Future<void> charger() async {
    chargement.value = true;
    erreur.value = null;
    final echecs = <String>[];

    Future<List<OeuvreBibliotheque>> lire(
        String nom,
        Future<List> Function() lireLignes,
        Iterable Function(Iterable) convertir,
        FamilleOeuvre famille,
        FormatOeuvre format) async {
      try {
        final lignes = await lireLignes();
        // Les managers attendent la liste enveloppée : GetGen(item) lit item[0].
        return [
          for (final element in convertir([lignes]))
            OeuvreBibliotheque(
                video: element["Video"] as Video,
                famille: famille,
                format: format)
        ];
      } catch (e) {
        debugPrint("[Bibliothèque] lecture « $nom » impossible : $e");
        echecs.add(nom);
        return const [];
      }
    }

    final parties = await Future.wait([
      lire('animes (séries)', ViewmodelAnimeserie.GetListAnimesSeries,
          ViewmodelAnimeserie.GetAnimesSeries, FamilleOeuvre.anime, FormatOeuvre.serie),
      lire('animes (films)', ViewmodelAnimefilm.GetListAnimesFilms,
          ViewmodelAnimefilm.GetAnimesFilms, FamilleOeuvre.anime, FormatOeuvre.film),
      lire('dramas (séries)', ViewmodelDramaserie.GetListDramasSeries,
          ViewmodelDramaserie.GetDramasSeries, FamilleOeuvre.drama, FormatOeuvre.serie),
      lire('dramas (films)', ViewmodelDramafilm.GetListDramasFilms,
          ViewmodelDramafilm.GetDramasFilms, FamilleOeuvre.drama, FormatOeuvre.film),
      lire('séries', ViewmodelSerie.GetListSeries, ViewmodelSerie.GetSeries,
          FamilleOeuvre.live, FormatOeuvre.serie),
      lire('films', ViewmodelFilm.GetListFilms, ViewmodelFilm.GetFilms,
          FamilleOeuvre.live, FormatOeuvre.film),
    ]);

    _toutes = parties.expand((p) => p).toList();
    if (echecs.isNotEmpty) {
      erreur.value = "Lecture impossible : ${echecs.join(', ')}.";
    }
    _appliquer();
    chargement.value = false;
  }

  void basculerFamille(FamilleOeuvre famille) {
    filtre.value = filtre.value.basculerFamille(famille);
    _appliquer();
  }

  void basculerFormat(FormatOeuvre format) {
    filtre.value = filtre.value.basculerFormat(format);
    _appliquer();
  }

  void rechercher(String texte) {
    filtre.value = filtre.value.copierAvec(recherche: texte);
    _appliquer();
  }

  void _appliquer() {
    oeuvres.value = filtre.value.appliquer(_toutes);
  }

  void dispose() {
    chargement.dispose();
    erreur.dispose();
    filtre.dispose();
    oeuvres.dispose();
  }
}
