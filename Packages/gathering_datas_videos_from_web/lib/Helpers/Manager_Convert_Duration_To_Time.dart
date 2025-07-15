part of gathering_data_videos_from_web;

enum _EnumerationUnitOfTime { MinutesOnly, HoursAndMinutes, MinutesAbove60 }

class ManagerConvertDurationToTime {
  late RegExpMatch resultOnRegex;
  late _EnumerationUnitOfTime _enumerationCompundUnitTime;
  late Map<_EnumerationUnitOfTime, String> _dictionnaryFormats;

  ManagerConvertDurationToTime(RegExpMatch result_regex_on_value) {
    this.resultOnRegex = result_regex_on_value;
    if (this.isRegexDoesNotContainAnyMarks()) {
      this._replaceRegexWithNewRegexWithMark();
    }
    this._enumerationCompundUnitTime = this._getEnumerationOfUnitOfTimeTarget();
    this._dictionnaryFormats = this._createDictionnary_UnitOfTimeAndFormat();
  }

  void _replaceRegexWithNewRegexWithMark() {
    var value = this.resultOnRegex.input.trim();
    final int count_find_unittime = RegExp("[0-9]+").allMatches(value).length;
    if (count_find_unittime == 2) {
      this.resultOnRegex = this
          ._returnNewRegexWithMarkForTimeStringThatContainsHoursAndMinutes(
              value);
    }
    if (count_find_unittime == 1) {
      this.resultOnRegex = this
          ._returnNewRegexWithMarkForTimeStringThatContainsMinutesOnly(value);
    }
  }

  RegExpMatch _returnNewRegexWithMarkForTimeStringThatContainsHoursAndMinutes(
      String input_of_regex) {
    const String PATTERN = "[0-9]+ *+[0-9]+";
    final String chaine_heure = RegExp("^[0-9]+").stringMatch(input_of_regex)!;
    final String chaine_minutes =
        RegExp("[0-9]+\$").stringMatch(input_of_regex)!;
    final String chaine_replace = "${chaine_heure}h ${chaine_minutes}m".trim();
    return RegExp("((?<hours>[0-9]+h)) +((?<minutes>[0-9]+m))")
        .firstMatch(chaine_replace)!;
  }

  RegExpMatch _returnNewRegexWithMarkForTimeStringThatContainsMinutesOnly(
      String input_of_regex) {
    const String PATTERN = "[0-9]+";
    final String chaine_minutes =
        RegExp("([0-9]+).*\$").firstMatch(input_of_regex)!.group(1)!;
    String time_string = "${chaine_minutes}".trim();
    final String chaine_replace = "${time_string}m";
    return RegExp("((?<minutes>[0-9]+m)){1}").firstMatch(chaine_replace)!;
  }

  _EnumerationUnitOfTime _getEnumerationOfUnitOfTimeTarget() {
    if (this.resultOnRegex.namedGroup("minutes") != null) {
      RegExpMatch? regex = RegExp("([0-9]+)")
          .firstMatch(this.resultOnRegex.namedGroup("minutes")!);
      int minutes = int.parse(regex!.group(1)!);
      if (minutes >= 60) {
        return _EnumerationUnitOfTime.MinutesAbove60;
      }
    }
    bool is_duree_contains_hours =
        RegExp("[hH]{1}").firstMatch(this.resultOnRegex.group(0)!) != null
            ? true
            : false;
    if (is_duree_contains_hours) {
      return _EnumerationUnitOfTime.HoursAndMinutes;
    }
    return _EnumerationUnitOfTime.MinutesOnly;
  }

  Map<_EnumerationUnitOfTime, String> _createDictionnary_UnitOfTimeAndFormat() {
    if (this._enumerationCompundUnitTime ==
            _EnumerationUnitOfTime.MinutesAbove60 ||
        this._enumerationCompundUnitTime ==
            _EnumerationUnitOfTime.HoursAndMinutes) {
      return this._createDictionnary_UnitOfTimeAndFormat_ForHoursAndMinutes();
    }
    return this._createDictionnary_UnitOfTimeAndFormat_ForMinutes();
  }

  Map<_EnumerationUnitOfTime, String>
      _createDictionnary_UnitOfTimeAndFormat_ForHoursAndMinutes() {
    const HOUR_MARCKER = "h";
    const MINUTES_MARCKER = "m";
    return {
      this._enumerationCompundUnitTime: "%H${HOUR_MARCKER}%M${MINUTES_MARCKER}"
    };
  }

  Map<_EnumerationUnitOfTime, String>
      _createDictionnary_UnitOfTimeAndFormat_ForMinutes() {
    const MINUTES_MARCKER = "m";
    return {this._enumerationCompundUnitTime: "%M${MINUTES_MARCKER}"};
  }

  flutter_type.TimeOfDay convertStringDurationToTime() =>
      this._convertStringDurationWithMark();

  bool _isContainsMarkHours() {
    return RegExp("[Hh]{1}").hasMatch(this.resultOnRegex.group(0)!)
        ? true
        : false;
  }

  bool _isContainsMarkMinutes() {
    return RegExp("[Mm]{1}").hasMatch(this.resultOnRegex.group(0)!)
        ? true
        : false;
  }

  bool isRegexDoesNotContainAnyMarks() =>
      !this._isContainsMarkHours() && !this._isContainsMarkMinutes();

  flutter_type.TimeOfDay _convertStringDurationWithMark() {
    if (this._enumerationCompundUnitTime ==
        _EnumerationUnitOfTime.MinutesAbove60) {
      return this._convertStringDurationThatHasValueMinutesAbove60IntoTime(
          this.resultOnRegex.namedGroup("minutes")!);
    }
    if (this._enumerationCompundUnitTime ==
        _EnumerationUnitOfTime.HoursAndMinutes) {
      return this._convertStringDurationThatHasValueHoursAndMinutes(
          hours: this.resultOnRegex.namedGroup("hours")!,
          minutes: this.resultOnRegex.namedGroup("minutes")!);
    }
    // exception possible à patcher !
    return this._convertStringDurationThatHasValueMinutesOnly(
        this.resultOnRegex.namedGroup("minutes")!);
  }

  flutter_type.TimeOfDay _convertStringDurationThatHasValueMinutesOnly(
      String minutes) {
    String minutes_formated = this._getTimeStringFormatedMinutesOnly(minutes);

    return flutter_type.TimeOfDay(
        hour: 0,
        minute: this
            ._getMinutesIntFromStringThatContainsCharacteres(minutes_formated));
  }

  flutter_type.TimeOfDay _convertStringDurationThatHasValueHoursAndMinutes(
      {required String hours, required String minutes}) {
    final String chaine_formated = this
        ._getTimeStringFormatedHoursAndMinutes(hours: hours, minutes: minutes);
    return flutter_type.TimeOfDay(
        hour:
            this._getHoursIntFromStringThatContainsCharacteres(chaine_formated),
        minute: this
            ._getMinutesIntFromStringThatContainsCharacteres(chaine_formated));
  }

  String _getTimeStringFormatedMinutesOnly(String minutes) {
    minutes = minutes.replaceAll(" ", "");
    return minutes;
  }

  String _getTimeStringFormatedHoursAndMinutes(
      {required String hours, required String minutes}) {
    hours = hours.replaceAll(" ", "");
    minutes = minutes.replaceAll(" ", "");
    return "${hours}${minutes}";
  }

  int _getMinutesIntFromStringThatContainsCharacteres(
          String numbers_in_string) =>
      int.parse(RegExp(_getRegexForChaineTimeFormated())
          .firstMatch(numbers_in_string)!
          .namedGroup("minutes")!);

  int _getHoursIntFromStringThatContainsCharacteres(String numbers_in_string) =>
      int.parse(RegExp(_getRegexForChaineTimeFormated())
          .firstMatch(numbers_in_string)!
          .namedGroup("hours")!);

  String _getRegexForChaineTimeFormated() =>
      "^((?<hours>[0-9]+)h|H)*((?<minutes>[0-9]+)m|M)*\$";

  flutter_type.TimeOfDay
      _convertStringDurationThatHasValueMinutesAbove60IntoTime(
          String minutes_input) {
    int total_minutes =
        int.parse(RegExp("([0-9]+)").firstMatch(minutes_input)!.group(1)!);
    dynamic hours = (total_minutes / 60).toInt();
    dynamic minutes = total_minutes % 60;
    hours = "${hours.toString()}h";
    minutes = "${minutes.toString()}m";
    String chaine = "${hours}${minutes}";
    return flutter_type.TimeOfDay(
        hour: this._getHoursIntFromStringThatContainsCharacteres(chaine),
        minute: this._getMinutesIntFromStringThatContainsCharacteres(chaine));
  }
}
