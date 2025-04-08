import 'package:flutter/material.dart';
import 'package:mediaproject/themes/light_mode.dart';
import 'package:mediaproject/themes/dark_mode.dart';

/*
THEME PROVIDER
라이트모드/다크모드 테마전환
 */

class ThemeProvider with ChangeNotifier{
  //초기값은 light mode로 설정
  ThemeData _themeData = lightMode;
  //테마 getter
  ThemeData get themeData => _themeData;
  //다크모드 설정여부 확인
  bool get isDarkMode => _themeData == darkMode;
  //테마 setter
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    //UI 갱신
    notifyListeners();
  }
  // 테마 변경
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}

