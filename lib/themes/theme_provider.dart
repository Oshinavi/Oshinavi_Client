import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'light_theme.dart';
import 'dark_theme.dart';

/// ThemeProvider:
/// - 다크/라이트 테마 토글 및 SharedPreferences에 상태 저장 기능 제공
/// - 앱 시작 시 저장된 선호 테마를 불러와 적용
class ThemeProvider extends ChangeNotifier {
  static const _keyIsDark = 'isDarkMode';

  late ThemeData _themeData;
  late bool _isDarkMode;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    // 앱 최초 실행 시 기본값을 라이트 모드로 설정하고 저장된 값이 있으면 덮어씌움
    _isDarkMode = false;
    _themeData = lightTheme;
    _loadFromPrefs();
  }

  /// toggleTheme:
  /// - _isDarkMode 플래그 반전
  /// - _themeData를 darkTheme 또는 lightTheme으로 변경
  /// - notifyListeners() 호출하여 UI 갱신
  /// - SharedPreferences에 변경된 값을 저장
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? darkTheme : lightTheme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, _isDarkMode);
  }

  /// _loadFromPrefs:
  /// - SharedPreferences에서 저장된 테마 모드 가져오기
  /// - 저장된 값이 있으면 _isDarkMode와 _themeData를 업데이트하고 notifyListeners() 호출
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_keyIsDark);
    if (saved != null) {
      _isDarkMode = saved;
      _themeData = _isDarkMode ? darkTheme : lightTheme;
      notifyListeners();
    }
  }
}