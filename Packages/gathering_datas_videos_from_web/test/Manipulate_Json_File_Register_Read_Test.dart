import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'Data_From_File_Register_For_Mocker.dart';

void main() {
  late ManipulateJsonFileRegister manipulateJsonFileRegister;

  setUpAll(() async {
    //ARRANGE
    manipulateJsonFileRegister = await ManipulateJsonFileRegister.create();
    manipulateJsonFileRegister.dataFromJson =
        DataFromFileRegisterForMocker.GetDataTest();
  });
  test("Return Identifiants notempty", () async {
    //ACT
    var identifiants =
        manipulateJsonFileRegister.manipulateJsonFileRead.getIdentifiants();
    //ASSERT
    expect(identifiants.length, greaterThan(0));
  });

  test("Return DictionnaryOfSiteData_is_instance_of_dictionnary", () {
    //ACT
    dynamic object = manipulateJsonFileRegister.manipulateJsonFileRead
        .getDictionnaryOfSiteData("https://site.B");
    //ASSERT
    expect(object, isA<Map>());
  });
  group("GetListSitesNames", () {
    test("return instance_of_list", () async {
      //ACT
      dynamic object =
          manipulateJsonFileRegister.manipulateJsonFileRead.getListSitesNames();
      //ASSERT
      expect(object, isA<List>());
    });

    test("contains instance_of_string", () async {
      //ACT
      dynamic object = manipulateJsonFileRegister.manipulateJsonFileRead
          .getListSitesNames()[0];
      //ASSERT
      expect(object, isA<String>());
    });
  });

  test("Return UrlReferenceSite in format Url ", () {
    //ACT
    dynamic object = manipulateJsonFileRegister.manipulateJsonFileRead
        .getUrlReferenceSite("OLKWYPMHGICP");
    //ASSERT
    expect(object, contains("http"));
  });

  test("Return UrlOfPageVideos in format Url", () {
    //ACT
    dynamic object = manipulateJsonFileRegister.manipulateJsonFileRead
        .getUrlOfPageVideos(
            identifiant: "OLKWYPMHGICP", categorie_video: "Video_Serie");
    //ASSERT
    expect(object, contains("http"));
  });

  group("GetListCategoriesVideo", () {
    test("Return instance of list", () {
      //ACT
      dynamic object = manipulateJsonFileRegister.manipulateJsonFileRead
          .getListCategoriesVideo("OLKWYPMHGICP");
      //ASSERT
      expect(object, isA<List>());
    });
    test("Contains instance of string", () {
      //ACT
      dynamic object = manipulateJsonFileRegister.manipulateJsonFileRead
          .getListCategoriesVideo("OLKWYPMHGICP")[0];
      //ASSERT
      expect(object, isA<String>());
    });
  });

  group("GetListTypeVideo__is_instance_of_list", () {
    test("Return instance of list", () {
      //ACT
      dynamic object = manipulateJsonFileRegister.manipulateJsonFileRead
          .getListTypeVideo(
              identifiant: "OLKWYPMHGICP", categorie: "Video_Serie");
      //ASSERT
      expect(object, isA<List>());
    });
    test("Contains instance of string", () {
      //ACT
      dynamic object = manipulateJsonFileRegister.manipulateJsonFileRead
          .getListTypeVideo(
              identifiant: "OLKWYPMHGICP", categorie: "AllCategories")[0];
      //ASSERT
      expect(object, isA<String>());
    });
  });
}
