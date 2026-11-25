import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';
import 'package:unistream/Models/Ajout_Oeuvre.dart';
import 'package:unistream/Services/Databases/Ajout_Oeuvre_Manager.dart';
import 'package:unistream/Services/Databases/Oeuvre_Lien_Manager.dart';
import 'package:unistream/Services/Features/Ajout_Oeuvre/Convertisseur_Ajout.dart';
import 'package:unistream/Services/Features/Download_Picture/Picture_Downloader.dart';
import 'package:unistream/Services/Features/Synchronisation/Api_Unistream.dart';

/// ViewModel de l'écran « Ajouter depuis le serveur » : rechercher → choisir une version → vérifier → ajouter.
///
/// Une seule SOURCE (les groupes renvoyés par le serveur) ; les deux onglets et les filtres en sont DÉRIVÉS
/// (getter `onglets`), jamais stockés : après un ajout, il suffit de rafraîchir l'état de la bibliothèque.
class ViewmodelAjoutOeuvre {
  final ApiUnistream _api;
  final AjoutOeuvreManager _bibliotheque;
  final OeuvreLienManager _liens;

  final ValueNotifier<bool> occupe = ValueNotifier(false); // lecture de fiche / ajout : bloque les actions
  final ValueNotifier<bool> chercheEnCours = ValueNotifier(false); // recherche : ne bloque PAS la saisie
  final ValueNotifier<String?> etape = ValueNotifier(null);
  final ValueNotifier<String?> erreur = ValueNotifier(null);
  final ValueNotifier<String?> message = ValueNotifier(null); // résultat d'une action, affiché une fois
  final ValueNotifier<String?> intitule = ValueNotifier(null); // « Nouveautés… » ou « Résultats pour … »
  final ValueNotifier<List<GroupeOeuvre>> groupes = ValueNotifier(const []);
  final ValueNotifier<EtatBibliotheque> bibliotheque = ValueNotifier(const EtatBibliotheque());
  final ValueNotifier<FiltresAjout> filtres = ValueNotifier(const FiltresAjout());
  final ValueNotifier<ApercuAjout?> apercu = ValueNotifier(null);

  Timer? _attente;
  int _requete = 0; // numéro de la dernière requête lancée : une réponse plus ancienne est ignorée
  List<GroupeOeuvre>? _nouveautes;

  static const delaiSaisie = Duration(milliseconds: 300);

  ViewmodelAjoutOeuvre._create(this._api, this._bibliotheque, this._liens);

  static Future<ViewmodelAjoutOeuvre> create() async {
    final vm = ViewmodelAjoutOeuvre._create(ApiUnistream(), AjoutOeuvreManager(), OeuvreLienManager());
    vm.bibliotheque.value = await vm._bibliotheque.etatBibliotheque();
    unawaited(vm._afficherNouveautes()); // l'écran s'ouvre sans attendre le réseau
    return vm;
  }

  bool get apiConfiguree => ApiUnistreamConfig.configuree;

  static const typesProposes = EnumerationFulltypeVideo.values;

  /// (à ajouter, dans ma bibliothèque), filtres appliqués.
  (List<GroupeOeuvre>, List<GroupeOeuvre>) get onglets =>
      ConvertisseurAjout.repartir(groupes.value, bibliotheque.value, filtres.value);

  bool possedee(VersionTrouvee v) => ConvertisseurAjout.possedee(v, bibliotheque.value);

  void basculerLangue(String l) => filtres.value = filtres.value.basculerLangue(l);
  void basculerFamille(String f) => filtres.value = filtres.value.basculerFamille(f);
  void effacerFiltres() => filtres.value = const FiltresAjout();

  // ─── Recherche ────────────────────────────────────────────────────────
  /// À chaque frappe : la recherche part 300 ms après la dernière touche (pas un appel par lettre).
  void saisir(String texte) {
    _attente?.cancel();
    final q = texte.trim();
    if (q.isEmpty) {
      _requete++; // annule une recherche en vol
      chercheEnCours.value = false;
      unawaited(_afficherNouveautes());
    } else if (q.length >= 2) {
      _attente = Timer(delaiSaisie, () => rechercher(q));
    }
  }

  /// Recherche immédiate (touche Entrée, bouton loupe).
  Future<void> rechercher(String texte) async {
    _attente?.cancel();
    final q = texte.trim();
    if (q.length < 2) return;
    await _charger(() async {
      final r = await _api.rechercher(q);
      // le serveur coupe au-delà de 200 versions : ce sont les correspondances les plus faibles qui manquent
      final coupe = r.total > r.resultats.length;
      return (
        ConvertisseurAjout.regrouper(_versions(r.resultats)),
        'Résultats pour « $q »${coupe ? ' — ${r.resultats.length} meilleurs sur ${r.total} : précise ta recherche' : ''}'
      );
    });
  }

  Future<void> _afficherNouveautes() async {
    if (_nouveautes != null) {
      _requete++;
      intitule.value = 'Nouveautés des 7 derniers jours';
      groupes.value = _nouveautes!;
      return;
    }
    await _charger(() async {
      _nouveautes = ConvertisseurAjout.regrouper(_versions(await _api.nouveautes()), trier: false);
      return (_nouveautes!, 'Nouveautés des 7 derniers jours');
    });
  }

  List<VersionTrouvee> _versions(List<dynamic> r) =>
      [for (final x in r) VersionTrouvee.depuisJson((x as Map).cast<String, dynamic>())];

  /// Réponses hors d'ordre : « nar » peut revenir APRÈS « naruto ». Seule la dernière requête lancée s'affiche.
  /// La requête rend (groupes, intitulé) ensemble : rien n'est partagé entre deux requêtes en vol.
  Future<void> _charger(Future<(List<GroupeOeuvre>, String)> Function() requete) async {
    final numero = ++_requete;
    chercheEnCours.value = true;
    erreur.value = null;
    try {
      final (r, libelle) = await requete();
      if (numero != _requete) return;
      apercu.value = null;
      intitule.value = libelle;
      groupes.value = r;
    } on ApiUnistreamException catch (e) {
      if (numero == _requete) erreur.value = e.message;
    } catch (e) {
      if (numero == _requete) erreur.value = 'Erreur inattendue : $e';
    } finally {
      if (numero == _requete) chercheEnCours.value = false;
    }
  }

  // ─── Choix, aperçu, ajout ─────────────────────────────────────────────
  Future<void> _executer(String libelle, Future<void> Function() action) async {
    occupe.value = true;
    erreur.value = null;
    etape.value = libelle;
    try {
      await action();
    } on ApiUnistreamException catch (e) {
      erreur.value = e.message;
    } catch (e) {
      erreur.value = 'Erreur inattendue : $e';
    } finally {
      occupe.value = false;
      etape.value = null;
    }
  }

  /// Lit les détails de la version choisie (cache du serveur, sinon le site : quelques secondes).
  Future<void> choisir(VersionTrouvee v) async {
    await _executer('Lecture de la fiche ${v.site} (${v.libelleLangues})…', () async {
      // langue inconnue : relecture forcée (age 0). Le cache du serveur peut dater d'avant la lecture de la langue.
      final details = await _api.details(v.urlFiche, idSite: v.idSite, ageMaxH: v.langues.isEmpty ? 0 : 168);
      final a = ConvertisseurAjout.apercu(v, details, dejaPresent: await _bibliotheque.titreExiste(v.titre));
      apercu.value = a;
      // la langue apprise s'affiche aussi dans la liste, au retour
      if (a.version.langues.isNotEmpty && v.langues.isEmpty) {
        final nouveautesAffichees = identical(groupes.value, _nouveautes);
        groupes.value = [
          for (final g in groupes.value)
            GroupeOeuvre(g.idOeuvre, g.titreOeuvre, g.famille,
                [for (final x in g.versions) x.cle == v.cle ? a.version : x])
        ];
        if (nouveautesAffichees) _nouveautes = groupes.value;
      }
    });
  }

  void fermerApercu() => apercu.value = null;

  void changerType(EnumerationFulltypeVideo type) {
    final a = apercu.value;
    if (a != null) apercu.value = a.copier(typeComplet: type);
  }

  Future<void> changerTitre(String titre) async {
    final a = apercu.value;
    final t = titre.trim();
    if (a == null || t.isEmpty || t == a.titre) return;
    apercu.value = a.copier(titre: t, dejaPresent: await _bibliotheque.titreExiste(t));
  }

  Future<void> ajouter() async {
    final a = apercu.value;
    if (a == null) return;
    await _executer('Ajout de « ${a.titre} »…', () async {
      // contrôle refait juste avant l'écriture : les insertions sont « insert or ignore », un doublon passerait
      // sans erreur et mélangerait deux œuvres sous le même titre
      if (await _bibliotheque.titreExiste(a.titre)) {
        apercu.value = a.copier(dejaPresent: true);
        erreur.value = '« ${a.titre} » est déjà dans la bibliothèque : change le titre pour l\'ajouter à part.';
        return;
      }
      etape.value = 'Téléchargement de l\'affiche…';
      final dossier = await ManagerOfLocationFolderFileOfApp.getFolderApp();
      // même repli que l'écran Enregistrements ; la synchronisation proposera l'affiche plus tard
      var lienAffiche = '${dossier.path}/video posters/visuals-NotFound-unsplash.jpg';
      var afficheOk = false;
      if (a.urlPoster != null) {
        final d = PictureDownloader(folder_app: dossier);
        if (await d.saveImage(url_poster: a.urlPoster!, referer: a.version.urlFiche)) {
          lienAffiche = d.filePath.path;
          afficheOk = true;
        }
      }
      etape.value = 'Écriture dans la bibliothèque…';
      final refus = await _bibliotheque.enregistrer(ConvertisseurAjout.versRegisterData(a, lienAffiche: lienAffiche));
      if (refus.isNotEmpty) {
        erreur.value = 'Ajout incomplet, refusé par : ${refus.toSet().join(', ')}';
        return;
      }
      // relié tout de suite : la synchronisation suivra cette version-là
      await _liens.lierManuellement(titre: a.titre, idOeuvre: a.version.idOeuvre, cleFiche: a.version.cle);
      bibliotheque.value = await _bibliotheque.etatBibliotheque(); // l'œuvre passe dans l'onglet 2
      apercu.value = null;
      message.value = '« ${a.titre} » ajouté'
          '${a.estSerie ? ' (${a.episodesParSaison.length} saison(s), ${a.nbEpisodes} épisode(s))' : ''}'
          '${afficheOk ? '' : ' — affiche non téléchargée'}';
    });
  }

  void dispose() {
    _attente?.cancel();
    for (final n in [occupe, chercheEnCours, etape, erreur, message, intitule, groupes, bibliotheque, filtres, apercu]) {
      n.dispose();
    }
  }
}
