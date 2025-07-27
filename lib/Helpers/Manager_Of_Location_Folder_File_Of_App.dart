import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ManagerOfLocationFolderFileOfApp {
  static Future<Directory> getFolderApp() async =>
      await getApplicationDocumentsDirectory();

  static Future<Directory> getFolderPictures() async {
    Directory directory_pictures = Directory(
        "${(await ManagerOfLocationFolderFileOfApp.getFolderApp()).path}/video posters");
    if (await directory_pictures.exists() == false) {
      return await directory_pictures.create();
    }
    return directory_pictures;
  }

  static Future<Directory> getFolderDatabase() async {
    Directory directory_database = Directory(
        "${(await ManagerOfLocationFolderFileOfApp.getFolderApp()).path}/databases");
    if (await directory_database.exists() == false) {
      return await directory_database.create();
    }
    return directory_database;
  }
}
