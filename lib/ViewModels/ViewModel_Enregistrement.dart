import 'package:unistream/Services/Databases/Video_Manager.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';

class ViewmodelEnregistrement {
  late ManipulateJsonFileRegister manipulateFileRegisterJson;
  late List<Map<String, dynamic>> dataFromJson;

  ViewmodelEnregistrement._create(
      ManipulateJsonFileRegister manipulateFileRegisterJson) {
    this.manipulateFileRegisterJson = manipulateFileRegisterJson;
    this.manipulateFileRegisterJson.checkConsistanceFile();
    this.dataFromJson = manipulateFileRegisterJson.dataFromJson;
  }

  Future<ViewmodelEnregistrement> create() async {
    return ViewmodelEnregistrement._create(
        await ManipulateJsonFileRegister.create());
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
    return ManagerGatheringData.convertAccesToIscrapeData(
            gathering_data.getObjectAcceesPage(
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
  }

  Future<List<RegisterData>> _getDataVideos(
      {required String identifiant,
      required String categorie,
      required int number_pages_to_scrape}) async {
    /*TODO*/
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
}
