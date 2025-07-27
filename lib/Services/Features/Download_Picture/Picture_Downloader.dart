import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PictureDownloader {
  late Directory _folderPicture;

  Directory get folderPicture => this._folderPicture;

  late File _filePath;

  File get filePath => this._filePath;

  PictureDownloader({required Directory folder_app}) {
    this._folderPicture = Directory("${folder_app.path}/video posters");
    this.createFolderPicture(_folderPicture);
  }

  void createFolderPicture(Directory folder_app) {
    folder_app.createSync();
  }

  Future<bool> saveImage({required String url_poster}) async {
    this._filePath =
        File("${this._folderPicture.path}/${url_poster.split("/").last}");
    return await this
        ._downloadImage(file_path: this._filePath, url_poster: url_poster);
  }

  Future<bool> _downloadImage(
      {required File file_path, required String url_poster}) async {
    final response = await this._getResponsePicture(url_poster: url_poster);
    if (response.statusCode != null) {
      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        return this._writeDataInFile(response.data);
      }
    }
    return false;
  }

  Future<Response> _getResponsePicture({required String url_poster}) async {
    late Response response_picture;
    try {
      response_picture = await Dio().get(url_poster,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              receiveTimeout: Duration(seconds: 0)));
    } on DioException catch (exception_dio) {
      debugPrint(
          "Save Image Failed : Une erreur est survenue lors de l'accées à la ressource, concernant le poster -> $exception_dio");
      return Response(requestOptions: RequestOptions());
    }
    return response_picture;
  }

  Future<bool> _writeDataInFile(List<int> data_of_response) async {
    try {
      final raf = this._filePath.openSync(mode: FileMode.write);
      raf.writeFromSync(data_of_response);
      await raf.close();
    } on FileSystemException catch (exception_filesystem) {
      debugPrint(
          "Save Image Failed : Une erreur est survenue lors de l'écriture des données dans le fichier -> $exception_filesystem");
      return false;
    }
    debugPrint("save img is succees :");
    return true;
  }
}
