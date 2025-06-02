import 'package:flutter/material.dart';

/// Twitter 앱 스타일의 다크 테마 색상 정의
final Color twitterDark        = Color(0xFFE1E8ED);
final Color twitterDarkBg      = Color(0xFF15202B);
final Color twitterDarkSurface = Color(0xFF192734);
final Color twitterDarkText    = Color(0xFFE1E8ED);

/// darkTheme:
/// - 다크 모드용 ThemeData 설정
/// - scaffoldBackgroundColor, primaryColor, appBarTheme 등 세부 설정 포함
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: twitterDarkBg,
  primaryColor: twitterDark,
  appBarTheme: AppBarTheme(
    backgroundColor: twitterDarkBg,
    foregroundColor: twitterDarkText, // 텍스트/아이콘 밝은 회색
    elevation: 0,
    titleTextStyle: TextStyle(
      color: twitterDarkText,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: twitterDarkText),
  ),
  colorScheme: ColorScheme.dark(
    primary: twitterDark,
    onPrimary: Colors.black,
    secondary: twitterDarkSurface,
    surface: twitterDarkSurface,
    background: twitterDarkBg,
    onBackground: twitterDarkText,
    onSurface: twitterDarkText,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: twitterDark,
      foregroundColor: Colors.black,
      shape: StadiumBorder(),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      elevation: 2,
    ),
  ),
  textTheme: TextTheme(
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: twitterDarkText,
    ),
    bodyMedium: TextStyle(fontSize: 14, color: twitterDarkText),
  ),
  dividerColor: Colors.white24,
);