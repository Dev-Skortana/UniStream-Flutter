import 'dart:io';
import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gathering_urls_videos_from_web/gathering_urls_videos_from_web.dart'
    show WebViewUserAgent;
import 'package:unistream/Database/Data_Initialize.dart';
import 'package:unistream/Helpers/Manager_Of_Location_Folder_File_Of_App.dart';
import 'package:unistream/Helpers/Manager_Permission.dart';
import 'package:unistream/Services/Databases/Reboot_Database_Manager.dart';
import 'package:unistream/Views/Helpers/Theme.dart';
import 'package:unistream/Views/Helpers/Son_Demarrage.dart';
import 'package:unistream/Views/Helpers/Theme_Controller.dart';
import 'package:unistream/Views/Splash/View_Splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Son d'ouverture : préparé pendant l'écran natif, en parallèle du reste.
  final sonDemarrage = await SonDemarrage.charger();
  final prechauffage = sonDemarrage.prechauffer();
  await saveFilesIntoApp();
  // Pré-charge le User-Agent de la WebView (facultatif : launch() le fait aussi).
  // Lancé sans await pour ne pas retarder l'affichage.
  WebViewUserAgent.init();
  // Thème choisi par l'utilisateur, lu avant le premier affichage
  // (sinon l'appli s'ouvrirait en clair puis basculerait).
  final themeController = await ThemeController.charger();
  // On attend le son au plus 800 ms : s'il n'est pas prêt, l'appli s'ouvre
  // sans lui plutôt que d'allonger l'écran natif.
  await prechauffage.timeout(const Duration(milliseconds: 800), onTimeout: () {});
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeController>.value(value: themeController),
      ChangeNotifierProvider<SonDemarrage>.value(value: sonDemarrage),
    ],
    child: const MyApp(),
  ));
}

Future<void> saveFilesIntoApp() async {
  //await RebootDatabaseManager().reboot();

  await saveFileFromAssetIntoFolderApp(
      path_file_from_asset:
          "assets/images/video_posters/visuals-NotFound-unsplash.jpg",
      directory_where_save:
          await ManagerOfLocationFolderFileOfApp.getFolderPictures(),
      file_fullname: "visuals-NotFound-unsplash.jpg");
  await saveFileFromAssetIntoFolderApp(
      path_file_from_asset: "assets/raw/Database_UniStream.db",
      directory_where_save:
          await ManagerOfLocationFolderFileOfApp.getFolderDatabase(),
      file_fullname: "Database_UniStream.db");
}

Future<void> saveFileFromAssetIntoFolderApp(
    {required String path_file_from_asset,
    required Directory directory_where_save,
    required String file_fullname}) async {
  File file_to_save = File("${directory_where_save.path}/${file_fullname}");
  if (file_to_save.existsSync() == false) {
    try {
      final ByteData database_bytes =
          await rootBundle.load(path_file_from_asset);
      List<int> bytes = database_bytes.buffer.asUint8List(
          database_bytes.offsetInBytes, database_bytes.lengthInBytes);
      await file_to_save.writeAsBytes(bytes, flush: true);
    } on FileSystemException catch (exception_filesystem) {
      debugPrint(
          "Une erreure est survenue lors de la sauvegarde du fichier -> $exception_filesystem");
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniStream',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: context.watch<ThemeController>().value,
      home: const ViewSplash(),
    );
  }
}