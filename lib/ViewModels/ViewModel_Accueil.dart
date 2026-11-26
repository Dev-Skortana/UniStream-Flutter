import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:unistream/Services/Databases/Historique_Manager.dart';
import 'package:unistream/Services/Features/Accueil/Selection_Accueil.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Bibliotheque/Lecture_Bibliotheque.dart';
import 'package:unistream/Services/Features/Historique/Suivi_Visionnage.dart';

/// État de l'Accueil : œuvre en vedette et rangées, filtrables par famille.
class ViewmodelAccueil {
  final ValueNotifier<bool> chargement = ValueNotifier(true);
  final ValueNotifier<String?> erreur = ValueNotifier(null);

  /// null = « Tout ».
  final ValueNotifier<FamilleOeuvre?> famille = ValueNotifier(null);
  final ValueNotifier<ContenuAccueil> contenu =
      ValueNotifier(const ContenuAccueil(null, []));

  List<OeuvreBibliotheque> _toutes = const [];

  /// Où en est l'utilisateur sur chaque œuvre regardée (titre → suivi).
  /// Mis à jour avec [contenu], donc lu dans le même rebuild.
  Map<String, SuiviOeuvre> suivis = const {};

  Future<void> charger() async {
    chargement.value = true;
    erreur.value = null;
    final (lu, suivisLus) = await (
      LectureBibliotheque.toutes(),
      HistoriqueManager().suivis(),
    ).wait;
    _toutes = lu.oeuvres;
    suivis = suivisLus;
    if (lu.echecs.isNotEmpty) {
      erreur.value = "Lecture impossible : ${lu.echecs.join(', ')}.";
    }
    _composer();
    chargement.value = false;
  }

  void choisirFamille(FamilleOeuvre? nouvelle) {
    famille.value = nouvelle;
    _composer();
  }

  void _composer() {
    contenu.value = SelectionAccueil.composer(_toutes,
        famille: famille.value, maintenant: DateTime.now(), suivis: suivis);
  }

  void dispose() {
    chargement.dispose();
    erreur.dispose();
    famille.dispose();
    contenu.dispose();
  }
}
