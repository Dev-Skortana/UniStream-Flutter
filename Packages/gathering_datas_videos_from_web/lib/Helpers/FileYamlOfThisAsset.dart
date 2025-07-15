import 'dart:convert';

import 'package:flutter/services.dart';

class GetAssetFileYamlForTest {
  static Future<String> getasset() async {
    var bytesdata_json = await rootBundle.load(
        "packages/gathering_datas_videos_from_web/assets/raw/scraping_register.yaml");

    return utf8.decode(Uint8List.sublistView(bytesdata_json));
  }
}
