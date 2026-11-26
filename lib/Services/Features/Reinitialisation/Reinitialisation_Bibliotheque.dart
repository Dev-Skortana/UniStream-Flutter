import 'dart:io';

import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';
import 'package:unistream/Services/Databases/Reboot_Database_Manager.dart';

/// Vide la bibliothèque : tables de la base et affiches téléchargées.
/// L'image de repli (copiée depuis assets/ au démarrage) est conservée.
///
/// Repris de l'ancien Accueil (View_Acceuille), déplacé dans Outils.
class ReinitialisationBibliotheque {
  static const String _imageDeRepli = 'visuals-NotFound-unsplash.jpg';

  static Future<void> toutEffacer() async {
    await RebootDatabaseManager().reboot();
    final dossier = await ManagerOfLocationFolderFileOfApp.getFolderPictures();
    if (!await dossier.exists()) return;
    await Future.wait([
      for (final fichier in dossier.listSync())
        if (fichier is File && !fichier.path.endsWith(_imageDeRepli))
          fichier.delete(),
    ]);
  }
}
