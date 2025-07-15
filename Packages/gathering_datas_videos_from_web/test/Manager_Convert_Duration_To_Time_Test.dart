import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';

void main() {
  const String PATTERNREGEX =
      "[^0-9]*((?<hours>[0-9] *h)){0,1} *((?<minutes>[0-9]+ *m)){0,1}";
  setUpAll(() {});

  group("test ResultOnRegex", () {
    test("Is_instance_of_match", () {
      //ARRANGE
      //ACT
      RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("1m")!;
      ManagerConvertDurationToTime manager_time =
          ManagerConvertDurationToTime(regex);
      dynamic result_regex = manager_time.resultOnRegex;
      //ASSERT
      expect(result_regex, isA<RegExpMatch>());
    });

    test("ResultOnRegex_have_group_hours", () {
      //ARRANGE
      //ACT
      RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("1h")!;
      ManagerConvertDurationToTime manager_time =
          ManagerConvertDurationToTime(regex);
      RegExpMatch result_regex = manager_time.resultOnRegex;
      //ASSERT
      expect(result_regex.namedGroup("hours"), isNotNull);
    });

    test("ResultOnRegex_have_group_minutes", () {
      //ARRANGE
      //ACT
      RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("40m")!;
      ManagerConvertDurationToTime manager_time =
          ManagerConvertDurationToTime(regex);
      RegExpMatch result_regex = manager_time.resultOnRegex;
      //ASSERT
      expect(result_regex.namedGroup("minutes"), isNotNull);
    });

    test("ResultOnRegex_have_group_hours_and__minute", () {
      //ARRANGE
      //ACT
      RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("1h 25m")!;
      ManagerConvertDurationToTime manager_time =
          ManagerConvertDurationToTime(regex);
      RegExpMatch result_regex = manager_time.resultOnRegex;
      //ASSERT
      expect(
          result_regex.namedGroup("minutes") != null &&
              result_regex.namedGroup("minutes") != null,
          isTrue);
    });
  });

  group("ConvertStringDuration_ToTime", () {
    group("WithMark", () {
      test("return_time_minutesonly", () {
        //ARRANGE
        //ACT
        RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("56m")!;
        ManagerConvertDurationToTime manager_time =
            ManagerConvertDurationToTime(regex);
        //ASSERT
        expect(manager_time.convertStringDurationToTime(),
            TimeOfDay(hour: 0, minute: 56));
      });

      test("return_time_hoursAndminutes", () {
        //ARRANGE
        //ACT
        RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("1h 56m")!;
        ManagerConvertDurationToTime manager_time =
            ManagerConvertDurationToTime(regex);
        //ASSERT
        expect(manager_time.convertStringDurationToTime(),
            TimeOfDay(hour: 1, minute: 56));
      });

      test("return_time_minutesabove60intotime", () {
        //ARRANGE
        //ACT
        RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("128m")!;
        ManagerConvertDurationToTime manager_time =
            ManagerConvertDurationToTime(regex);
        //ASSERT
        expect(manager_time.convertStringDurationToTime(),
            TimeOfDay(hour: 2, minute: 8));
      });
    });
    group("WithoutMark", () {
      test("return_time_minutesonly", () {
        //ARRANGE
        //ACT
        RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("49")!;
        ManagerConvertDurationToTime manager_time =
            ManagerConvertDurationToTime(regex);
        //ASSERT
        expect(manager_time.convertStringDurationToTime(),
            TimeOfDay(hour: 0, minute: 49));
      });

      test("return_time_hoursAndminutes", () {
        //ARRANGE
        //ACT
        RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("2 49")!;
        ManagerConvertDurationToTime manager_time =
            ManagerConvertDurationToTime(regex);
        //ASSERT
        expect(manager_time.convertStringDurationToTime(),
            TimeOfDay(hour: 2, minute: 49));
      });

      test("return_time_minutesabove60intotime", () {
        //ARRANGE
        //ACT
        RegExpMatch regex = RegExp(PATTERNREGEX).firstMatch("168")!;
        ManagerConvertDurationToTime manager_time =
            ManagerConvertDurationToTime(regex);
        //ASSERT
        expect(manager_time.convertStringDurationToTime(),
            TimeOfDay(hour: 2, minute: 48));
      });
    });
  });
}
