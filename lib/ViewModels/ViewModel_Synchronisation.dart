import 'package:flutter/foundation.dart';
import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';
import 'package:unistream/Models/Synchronisation.dart';
import 'package:unistream/Services/Databases/Oeuvre_Lien_Manager.dart';
import 'package:unistream/Services/Databases/Synchronisation_Manager.dart';
import 'package:unistream/Services/Features/Download_Picture/Picture_Downloader.dart';
import 'package:unistream/Services/Features/Synchronisation/Api_Unistream.dart';
import 'package:unistream/Services/Features/Synchronisation/Comparateur_Synchronisation.dart';

/// ViewModel de l'écran Synchronisation. La vue n'écoute que les ValueNotifier ci-dessous et appelle les
/// méthodes publiques ; tout accès réseau / base passe par les Services.
class ViewmodelSynchronisation {
  final ApiUnistream _api;
  final OeuvreLienManager _liens;
  final SynchronisationManager _synchro;

  final ValueNotifier<bool> occupe = ValueNotifier(false);
  final ValueNotifier<String?> etape = ValueNotifier(null);
  final ValueNotifier<String?> erreur = ValueNotifier(null);
  final ValueNotifier<String?> message = ValueNotifier(null); // résultat d'une action, à afficher une fois
  final ValueNotifier<(int, int)> titresRelies = ValueNotifier((0, 0)); // (reliés, total)
  final ValueNotifier<int> aValider = ValueNotifier(0);
  final ValueNotifier<List<ApercuOeuvre>> apercus = ValueNotifier(const []);
  final ValueNotifier<int> enFile = ValueNotifier(0);
  final ValueNotifier<Set<String>> selection = ValueNotifier(const {}); // titres cochés pour l'écriture

  final Map<String, EtatLocal> _etats = {};

  ViewmodelSynchronisation._create(this._api, this._liens, this._synchro);

  static Future<ViewmodelSynchronisation> create() async {
    final vm = ViewmodelSynchronisation._create(ApiUnistream(), OeuvreLienManager(), SynchronisationManager());
    await vm._chargerCompteurs();
    return vm;
  }

  bool get apiConfiguree => ApiUnistreamConfig.configuree;

  List<ApercuOeuvre> get aMettreAJour => apercus.value.where((a) => a.changements.isNotEmpty).toList();
  Map<TypeChangement, int> get parType => ComparateurSynchronisation.compterParType(apercus.value);
  int get sansDetails => apercus.value.where((a) => !a.detailsDisponibles).length;

  Future<void> _chargerCompteurs() async {
    titresRelies.value = ((await _liens.getList()).length, await _liens.countTitres());
  }

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

  /// Relie les titres de la bibliothèque aux œuvres du serveur (n'écrit que dans Oeuvres_Liens).
  Future<void> relier() => _executer('Rapprochement des titres…', () async {
        final r = await _api.rapprocher(await _liens.getTitresPourRapprochement());
        await _liens.insertLiensSurs(r['sures'] as List);
        aValider.value = (r['a_valider'] as List).length;
        await _chargerCompteurs();
      });

  /// Calcule ce que la synchronisation changerait. Rien n'est écrit dans la bibliothèque.
  Future<void> calculerApercu() => _executer('Lecture des données du serveur…', () async {
        final liens = await _liens.getList();
        final r = await _api.sync([
          for (final l in liens) {'id_oeuvre': l['Id_Oeuvre'], 'cle_fiche': l['Cle_Fiche']}
        ]);
        final elements = r['elements'] as List;
        final out = <ApercuOeuvre>[];
        _etats.clear();
        for (var i = 0; i < liens.length && i < elements.length; i++) {
          final titre = liens[i]['Titre'] as String;
          final e = (elements[i] as Map).cast<String, dynamic>();
          if (e['erreur'] != null) {
            out.add(ApercuOeuvre(titre: titre, avertissement: '${e['erreur']}', detailsDisponibles: false));
            continue;
          }
          if (e['redirigee'] == true) await _liens.updateIdOeuvre(titre, e['id_oeuvre'] as int);
          final details = (e['details'] as Map?)?.cast<String, dynamic>();
          final fiche = (e['fiche'] as Map?)?.cast<String, dynamic>();
          final local = await _liens.getEtatLocal(titre);
          _etats[titre] = local;
          out.add(ApercuOeuvre(
            titre: titre,
            idOeuvre: e['id_oeuvre'] as int?,
            site: fiche?['site'] as String?,
            urlFiche: fiche?['url_fiche'] as String?,
            detailsDisponibles: details != null,
            avertissement: e['avertissement'] as String?,
            changements: ComparateurSynchronisation.comparer(local, details, fiche),
          ));
        }
        apercus.value = out;
        enFile.value = (r['en_file'] as num).toInt();
        selection.value = {for (final a in out) if (a.changements.isNotEmpty) a.titre};
      });

  void basculer(String titre) {
    final s = {...selection.value};
    s.contains(titre) ? s.remove(titre) : s.add(titre);
    selection.value = s;
  }

  void toutSelectionner(bool oui) =>
      selection.value = oui ? {for (final a in aMettreAJour) a.titre} : const {};

  /// Écrit les changements des œuvres cochées, après une sauvegarde de la base.
  /// Une œuvre en erreur (affiche introuvable, contrainte SQL…) est signalée sans arrêter les autres.
  Future<BilanSynchronisation?> appliquer() async {
    BilanSynchronisation? bilan;
    await _executer('Sauvegarde de la base…', () async {
      final cibles = aMettreAJour.where((a) => selection.value.contains(a.titre)).toList();
      if (cibles.isEmpty) return;
      final sauvegarde = await _synchro.sauvegarder();
      final dossier = await ManagerOfLocationFolderFileOfApp.getFolderApp();
      var oeuvres = 0, changements = 0;
      final erreurs = <String>[];
      for (final (i, a) in cibles.indexed) {
        etape.value = 'Mise à jour ${i + 1}/${cibles.length} : ${a.titre}';
        final local = _etats[a.titre] ?? await _liens.getEtatLocal(a.titre);
        var aEcrire = a.changements;
        String? cheminAffiche;
        final affiche = a.changements.where((c) => c.type == TypeChangement.affiche).firstOrNull;
        if (affiche != null) {
          // téléchargement AVANT la transaction : un réseau lent ne bloque pas la base
          final d = PictureDownloader(folder_app: dossier);
          if (await d.saveImage(url_poster: '${affiche.valeur}', referer: a.urlFiche)) {
            cheminAffiche = d.filePath.path;
          } else {
            erreurs.add('${a.titre} : affiche non téléchargée (gardée telle quelle)');
            aEcrire = aEcrire.where((c) => c.type != TypeChangement.affiche).toList();
          }
        }
        try {
          final n = await _synchro.appliquer(local, aEcrire, cheminAffiche: cheminAffiche);
          if (n > 0) oeuvres++;
          changements += n;
        } catch (e) {
          erreurs.add('${a.titre} : $e');
        }
      }
      bilan = BilanSynchronisation(
          oeuvresMisesAJour: oeuvres, changementsAppliques: changements, erreurs: erreurs, sauvegarde: sauvegarde);
      message.value = '$oeuvres œuvre(s) mise(s) à jour ($changements changement(s))'
          '${erreurs.isEmpty ? '' : ', ${erreurs.length} problème(s)'}. Sauvegarde faite avant l\'écriture.';
      apercus.value = const [];
      selection.value = const {};
    });
    return bilan;
  }

  /// Remet la base telle qu'avant la dernière synchronisation.
  Future<void> annulerDerniere() => _executer('Restauration de la sauvegarde…', () async {
        final s = await _synchro.getSauvegardes();
        if (s.isEmpty) {
          message.value = 'Aucune sauvegarde à restaurer.';
          return;
        }
        await _synchro.restaurer(s.first);
        apercus.value = const [];
        await _chargerCompteurs();
        message.value = 'Base restaurée. Redémarre l\'appli pour que tous les écrans la rechargent.';
      });

  void dispose() {
    for (final n in [occupe, etape, erreur, message, titresRelies, aValider, apercus, enFile, selection]) {
      n.dispose();
    }
  }
}
