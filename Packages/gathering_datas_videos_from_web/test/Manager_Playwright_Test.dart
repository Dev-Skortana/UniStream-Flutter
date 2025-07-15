import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:puppeteer/src/browser.dart';

void main() {
  late ManagerPlaywright manager_playgright;
  setUpAll(() {
    manager_playgright = ManagerPlaywright();
  });
  group("getPlaywright", () {
    test("Return type of Browser", () async {
      //ARRANGE
      //ACT
      dynamic value = await manager_playgright.getPlaywright(false);
      //ASSERT
      expect(value, isA<Browser>());
    });
  });
}
