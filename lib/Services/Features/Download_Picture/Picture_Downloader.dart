import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PictureDownloader {
  late Directory _folderPicture;

  Directory get folderPicture => this._folderPicture;

  late File _filePath;

  File get filePath => this._filePath;

  /// User-Agent de navigateur : beaucoup de serveurs d'images refusent (403)
  /// le User-Agent par défaut de Dio.
  static const String _userAgent =
      'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36';

  PictureDownloader({required Directory folder_app}) {
    this._folderPicture = Directory("${folder_app.path}/video posters");
    this.createFolderPicture(_folderPicture);
  }

  void createFolderPicture(Directory folder_app) {
    folder_app.createSync(recursive: true);
  }

  /// [referer] : URL de la page (ou du site) d'où vient l'affiche,
  /// par ex. "https://voirdrama.to/". Indispensable pour les serveurs qui
  /// bloquent le « hotlinking » (erreur 403). Sans valeur, on utilise
  /// l'origine de l'image elle-même.
  Future<bool> saveImage({required String url_poster, String? referer}) async {
    this._filePath =
        File("${this._folderPicture.path}/${_fileNameFromUrl(url_poster)}");
    return await this._downloadImage(
        file_path: this._filePath, url_poster: url_poster, referer: referer);
  }

  /// Nom de fichier sans la query string (?w=300…), qui casserait le chemin.
  String _fileNameFromUrl(String url_poster) {
    final Uri? uri = Uri.tryParse(url_poster);
    final String last = (uri != null && uri.pathSegments.isNotEmpty)
        ? uri.pathSegments.last
        : url_poster.split("/").last;
    return last.isEmpty ? "poster_${url_poster.hashCode}.jpg" : last;
  }

  Future<bool> _downloadImage(
      {required File file_path,
      required String url_poster,
      String? referer}) async {
    final response = await this
        ._getResponsePicture(url_poster: url_poster, referer: referer);
    if (response.statusCode != null) {
      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        return this._writeDataInFile(response.data);
      }
    }
    return false;
  }

  Future<Response> _getResponsePicture(
      {required String url_poster, String? referer}) async {
    late Response response_picture;
    final Uri? uri = Uri.tryParse(url_poster);
    final String referer_value =
        referer ?? (uri != null && uri.hasScheme ? "${uri.origin}/" : "");
    try {
      response_picture = await Dio().get(url_poster,
          options: Options(
              responseType: ResponseType.bytes,
              // Les CDN d'images redirigent souvent (301/302) : on suit.
              followRedirects: true,
              maxRedirects: 5,
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'User-Agent': _userAgent,
                'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
                if (referer_value.isNotEmpty) 'Referer': referer_value,
              }));
    } on DioException catch (exception_dio) {
      debugPrint(
          "Save Image Failed : Une erreur est survenue lors de l'accées à la ressource, concernant le poster ($url_poster, Referer: $referer_value) -> ${exception_dio.response?.statusCode ?? exception_dio.type}");
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