import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';

void main() {
  late BuilderIdentifiants builder_identifiants;
  setUpAll(() {
    builder_identifiants = BuilderIdentifiants();
  });

  group("getIdentifiants", () {
    test("Return right Type", () {
      //ARRANGE
      //ACT
      dynamic identifiants =
          builder_identifiants.getIdentifiants(how_many_identifiers: 7);
      //ASSERT
      expect(identifiants, isA<List<String>>());
    });

    test("Return Values", () {
      //ARRANGE
      //ACT
      List<String> identifiants =
          builder_identifiants.getIdentifiants(how_many_identifiers: 2);
      //ASSERT
      expect(identifiants, isNotEmpty);
    });
    test("Return right count of values", () {
      //ARRANGE
      //ACT
      List<String> identifiants =
          builder_identifiants.getIdentifiants(how_many_identifiers: 7);
      //ASSERT
      expect(identifiants.length, 7);
    });
    test("Return right count of char in a identifiant", () {
      //ARRANGE
      //ACT
      List<String> identifiants = builder_identifiants.getIdentifiants(
          how_many_identifiers: 7, length: 12);
      //ASSERT
      expect(identifiants.first.length, 12);
    });
  });
}
