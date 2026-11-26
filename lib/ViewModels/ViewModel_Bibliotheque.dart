import 'package:flutter/foundation.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Bibliotheque/Lecture_Bibliotheque.dart';

/// Toute la bibliothèque (animes, dramas, séries, films) dans une seule liste
/// filtrable, à la place des 4 onglets qui montraient une œuvre à la fois.
///
/// Même modèle que ViewModel_Synchronisation / ViewModel_Ajout_Oeuvre :
/// l'état est exposé en ValueNotifier, la vue écoute et appelle les méthodes.
/// La lecture en base est partagée avec l'Accueil (LectureBibliotheque).
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
    final contenu = await LectureBibliotheque.toutes();
    _toutes = contenu.oeuvres;
    if (contenu.echecs.isNotEmpty) {
      erreur.value = "Lecture impossible : ${contenu.echecs.join(', ')}.";
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
