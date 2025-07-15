import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'Data_From_File_Register_For_Mocker.dart';

void main() {
  setUpAll(() {});
  group("GetDataFromJson", () {
    test("return values", () async {
      //ARRANGE
      //ACT
      final manipulateJsonFileRegister =
          await ManipulateJsonFileRegister.create();
      // manipulateJsonFileRegister.dataFromJson =DataFromFileRegisterForMocker.GetDataTest();
      //ASSERT
      print(manipulateJsonFileRegister.dataFromJson);
      expect(manipulateJsonFileRegister.dataFromJson.length, greaterThan(0));
    });
  });
}
