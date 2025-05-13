import 'package:flutter/material.dart';
import 'package:mediaproject/themes/light_mode.dart';
import 'package:mediaproject/themes/dark_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
THEME PROVIDER
라이트모드/다크모드 테마전환
 */
class ThemeProvider with ChangeNotifier {
  static const _keyIsDark = 'isDarkMode';

  late ThemeData _themeData;
  late bool _isDarkMode;

  ThemeProvider() {
    // 초기값: 일단 라이트로 세팅해두고, prefs에서 덮어씁니다.
    _isDarkMode = false;
    _themeData = lightMode;
    _loadFromPrefs();
  }

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;

  /// 토글할 때마다 저장
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? darkMode : lightMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, _isDarkMode);
  }

  /// 앱 시작 시 호출: prefs에서 읽어서 실제 테마로 반영
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_keyIsDark);
    if (saved != null) {
      _isDarkMode = saved;
      _themeData = _isDarkMode ? darkMode : lightMode;
      notifyListeners();
    }
  }
}