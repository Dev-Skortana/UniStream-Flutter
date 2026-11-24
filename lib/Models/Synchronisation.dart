// Données de la synchronisation avec l'API UniStream (aucune logique ici).

/// Ce que la bibliothèque de l'appli contient pour un titre.
class EtatLocal {
  final String titre;
  final String? description;
  final String? duree; // « HH:MM:SS » (colonne Videos.Duree)
  final String? dateParution; // « AAAA-MM-JJ »
  final String? lienAffiche; // chemin du fichier sur l'appareil (affiché avec Image.file)
  final bool afficheExiste; // le fichier d'affiche existe-t-il sur CET appareil ?
  final bool estSerie; // présent dans Videos_Series (les épisodes ne concernent que les séries)
  final Map<int, int> episodesParSaison; // Details_Videos_Series : saison → nombre d'épisodes
  final Map<int, int> dernierEpisodeParSaison; // saison → plus grand numéro d'épisode enregistré

  const EtatLocal({
    required this.titre,
    this.description,
    this.duree,
    this.dateParution,
    this.lienAffiche,
    this.afficheExiste = false,
    this.estSerie = false,
    this.episodesParSaison = const {},
    this.dernierEpisodeParSaison = const {},
  });
}

enum TypeChangement { description, duree, annee, affiche, episodes, saison }

/// Un changement proposé. [avant]/[apres] servent à l'affichage ; [valeur] et [saison] à l'écriture.
class Changement {
  final TypeChangement type;
  final String avant;
  final String apres;
  final Object? valeur; // texte complet, « HH:MM:SS », « AAAA-MM-JJ », adresse d'affiche, nombre d'épisodes
  final int? saison;

  const Changement(this.type, this.avant, this.apres, {this.valeur, this.saison});

  String get libelle => switch (type) {
        TypeChangement.description => 'Description',
        TypeChangement.duree => 'Durée',
        TypeChangement.annee => 'Date de parution',
        TypeChangement.affiche => 'Affiche',
        TypeChangement.episodes => 'Épisodes',
        TypeChangement.saison => 'Nouvelle saison',
      };

  @override
  String toString() => '$libelle : $avant → $apres';
}

/// Résultat de l'aperçu pour une œuvre de la bibliothèque.
class ApercuOeuvre {
  final String titre;
  final int? idOeuvre;
  final String? site;
  final String? urlFiche; // sert de Referer au téléchargement de l'affiche
  final List<Changement> changements;
  final bool detailsDisponibles; // false : fiche pas encore lue par le serveur (en file pour la nuit)
  final String? avertissement;

  const ApercuOeuvre({
    required this.titre,
    this.idOeuvre,
    this.site,
    this.urlFiche,
    this.changements = const [],
    this.detailsDisponibles = true,
    this.avertissement,
  });
}

/// Bilan d'une synchronisation appliquée.
class BilanSynchronisation {
  final int oeuvresMisesAJour;
  final int changementsAppliques;
  final List<String> erreurs; // « titre : raison » — une œuvre en erreur n'empêche pas les autres
  final String? sauvegarde; // chemin de la copie de la base faite AVANT l'écriture

  const BilanSynchronisation(
      {this.oeuvresMisesAJour = 0, this.changementsAppliques = 0, this.erreurs = const [], this.sauvegarde});
}
