import 'package:flutter/material.dart';
import 'package:unistream/Views/Helpers/Theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => this._themeData;

  void set themeData(ThemeData value) {
    this._themeData = value;
    notifyListeners();
  }

  void toogleTheme() {
    this.themeData = this._themeData == lightMode ? darkMode : lightMode;
  }
}
