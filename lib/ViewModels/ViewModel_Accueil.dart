import 'package:flutter/foundation.dart';
import 'package:unistream/Services/Features/Accueil/Selection_Accueil.dart';
import 'package:unistream/Services/Features/Bibliotheque/Filtre_Bibliotheque.dart';
import 'package:unistream/Services/Features/Bibliotheque/Lecture_Bibliotheque.dart';

/// État de l'Accueil : œuvre en vedette et rangées, filtrables par famille.
class ViewmodelAccueil {
  final ValueNotifier<bool> chargement = ValueNotifier(true);
  final ValueNotifier<String?> erreur = ValueNotifier(null);

  /// null = « Tout ».
  final ValueNotifier<FamilleOeuvre?> famille = ValueNotifier(null);
  final ValueNotifier<ContenuAccueil> contenu =
      ValueNotifier(const ContenuAccueil(null, []));

  List<OeuvreBibliotheque> _toutes = const [];

  Future<void> charger() async {
    chargement.value = true;
    erreur.value = null;
    final lu = await LectureBibliotheque.toutes();
    _toutes = lu.oeuvres;
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
        famille: famille.value, maintenant: DateTime.now());
  }

  void dispose() {
    chargement.dispose();
    erreur.dispose();
    famille.dispose();
    contenu.dispose();
  }
}
