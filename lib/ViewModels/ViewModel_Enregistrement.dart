import 'dart:io';

import 'package:unistream/Helpers/Use_Dictionnary_FullTypeVideo_ListServiceManager.dart';
import 'package:unistream/Helpers/Use_Dictionnary_ServiceManager_BaseModel.dart';
import 'package:unistream/Models/Templates/Base_Model.dart';
import 'package:unistream/Services/Databases/Interface/ILoad_Manager_Database.dart';
import 'package:unistream/Services/Databases/Video_Manager.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';

import 'package:path_provider/path_provider.dart';
import 'package:unistream/Services/Features/Download_Picture/Picture_Downloader.dart';

import 'package:collection/collection.dart';

class ViewmodelEnregistrement {
  late ManipulateJsonFileRegister manipulateFileRegisterJson;
  late List<Map<String, dynamic>> dataFromJson;

  ViewmodelEnregistrement._create(this.manipulateFileRegisterJson) {
    this.manipulateFileRegisterJson.checkConsistanceFile();
    this.dataFromJson = manipulateFileRegisterJson.dataFromJson;
  }

  static Future<ViewmodelEnregistrement> create() async {
    ViewmodelEnregistrement viewmodel = ViewmodelEnregistrement._create(
        await ManipulateJsonFileRegister.create());
    return viewmodel;
  }

  Iterable<String> getListSitesNames() => this
      .manipulateFileRegisterJson
      .manipulateJsonFileRead
      .getListSitesNames();

  Iterable<String> getListIdentifiants() =>
      this.manipulateFileRegisterJson.manipulateJsonFileRead.getIdentifiants();

  Iterable<String> getListCategoriesVideo(String identifiant) {
    Iterable<String> categories = this
        .manipulateFileRegisterJson
        .manipulateJsonFileRead
        .getListCategoriesVideo(identifiant);
    return this.isAllCategories(categories.first)
        ? this.getAllCategories()
        : categories;
  }

  bool isAllCategories(String categorie) =>
      EnumerationCategorieVideo.values.byName(categorie) ==
      EnumerationCategorieVideo.AllCategories;

  Iterable<String> getAllCategories() => [
        EnumerationCategorieVideo.AllCategories.name,
        EnumerationCategorieVideo.Video_Film.name,
        EnumerationCategorieVideo.Video_Serie.name
      ];

  Iterable<String> getListTypeVideo(
          {required String identifiant, required String categorie}) =>
      this
          .manipulateFileRegisterJson
          .manipulateJsonFileRead
          .getListTypeVideo(identifiant: identifiant, categorie: categorie);

  Future<int> getPagesNumbersMaximum(
      {required String identifiant, required String categorie}) async {
    String url_reference = this
        .manipulateFileRegisterJson
        .manipulateJsonFileRead
        .getUrlReferenceSite(identifiant);
    ManagerGatheringData gathering_data = ManagerGatheringData();
    return await ManagerGatheringData.convertAccesToIscrapeData(
            await gathering_data.getObjectAcceesPage(
                url_reference_fromjson: url_reference,
                targetcategorievideo: categorie))
        .getNumbersOfPages();
  }

  Future startRecording(
      {required String identifiant,
      required String categorie,
      required int number_pages_to_scrape}) async {
    /*TODO*/
    List<RegisterData> liste_data_videos = await this._getDataVideos(
        identifiant: identifiant,
        categorie: categorie,
        number_pages_to_scrape: number_pages_to_scrape);
    List<Future> tasks_insert_data_to_database = List.empty(growable: true);
    for (RegisterData data_videos_gathering in liste_data_videos) {
      UseDictionnaryFulltypevideoListservicemanager
          dictionnaryFulltypevideoListservicemanager =
          UseDictionnaryFulltypevideoListservicemanager();
      List<dynamic> types_services_manager_database_of_fulltype_video =
          dictionnaryFulltypevideoListservicemanager
                  .DictionnaryFullTypeVideoListServiceManager[
              data_videos_gathering.fullType_Video.name]!["Types"];

      List<dynamic> instances_services_manager_database_of_fulltype_video =
          dictionnaryFulltypevideoListservicemanager
                  .DictionnaryFullTypeVideoListServiceManager[
              data_videos_gathering.fullType_Video.name]!["Instances"];

      for (var item in IterableZip<dynamic>([
        types_services_manager_database_of_fulltype_video,
        instances_services_manager_database_of_fulltype_video
      ])) {
        var type_service_manager = item[0];
        var instance_service_manager = item[1];
        UseDictionnaryServicemanagerBasemodel
            dictionnary_servicemanager_basemodel =
            UseDictionnaryServicemanagerBasemodel(data_videos_gathering);
        dynamic contenair_base_model = dictionnary_servicemanager_basemodel
            .DictionnaryServiceManagerBaseModel[type_service_manager];
        if (contenair_base_model != null) {
          if (contenair_base_model is List) {
            for (BaseModel base_model in contenair_base_model) {
              Future task = Future(() {
                this._insertIntoDatabase(
                    service_manager: instance_service_manager(),
                    base_model: base_model);
              });
              tasks_insert_data_to_database.add(task);
            }
          } else {
            Future task = Future(() {
              this._insertIntoDatabase(
                  service_manager: instance_service_manager(),
                  base_model: contenair_base_model);
            });
            tasks_insert_data_to_database.add(task);
          }
        }
      }
    }
    await Future.wait(tasks_insert_data_to_database);
  }

  Future<List<RegisterData>> _getDataVideos(
      {required String identifiant,
      required String categorie,
      required int number_pages_to_scrape}) async {
    String urlsite_reference = this
        .manipulateFileRegisterJson
        .manipulateJsonFileRead
        .getUrlReferenceSite(identifiant);
    ManagerGatheringData gathering_data = ManagerGatheringData(
        categorie_video_target:
            EnumerationCategorieVideo.values.byName(categorie),
        numpagebegenning: number_pages_to_scrape);
    await gathering_data.asyncGatheringDataWithUrl(urlsite_reference);
    return gathering_data.listDataVideo;
  }

  void _insertIntoDatabase(
      {required IloadManagerDatabase service_manager,
      required base_model}) async {
    //TODO
    if (service_manager is VideoManager) {
      this._insertVideoWithhisPoster(
          service_manager: service_manager, base_model: base_model);
    } else {
      service_manager.insert(base_model);
    }
  }

  void _insertVideoWithhisPoster(
      {required IloadManagerDatabase service_manager,
      required base_model}) async {
    //TODO
    bool is_insert_completed = await service_manager.insert(base_model);
    if (this._isPosterToDownload(
        is_insert_completed: is_insert_completed,
        url_poster: base_model.lienAffiche)) {
      final Directory appstorage = await getApplicationDocumentsDirectory();
      final Directory folder_picture =
          await Directory("${appstorage.path}/video posters").create();
      final PictureDownloader picture_downloader =
          PictureDownloader(folder_app: appstorage);
      bool is_poster_saved = await picture_downloader.saveImage(
          url_poster: base_model.lienAffiche);

      final File download_file = File(
          "${folder_picture.path}/${this._getNameFilePosterToInclude(is_poster_saved: is_poster_saved, url_poster: base_model.lienAffiche)}");
      (service_manager as VideoManager)
          .UpdateFieldPoster(base_model.titre, download_file.path);
    }
  }

  bool _isPosterToDownload(
      {required bool is_insert_completed, required String url_poster}) {
    return is_insert_completed &&
        this._isUrlImageHasValueAndComplete(url_poster);
  }

  String _getNameFilePosterToInclude(
      {required bool is_poster_saved, required String url_poster}) {
    if (is_poster_saved)
      return url_poster.split("/").last;
    else
      return "visuals-NotFound-unsplash.jpg";
  }

  bool _isUrlImageHasValueAndComplete(String url_poster) {
    return url_poster.contains("http");
  }
}
