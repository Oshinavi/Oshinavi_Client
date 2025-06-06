import 'package:flutter/material.dart';

/// Twitter 앱 스타일의 라이트 테마 색상 정의
final Color twitterBlue     = Color(0xFF1DA1F2);
final Color twitterGray100  = Color(0xFFF5F8FA);
final Color twitterGray200  = Color(0xFFE1E8ED);
final Color twitterGray900  = Color(0xFF14171A);

/// lightTheme:
/// - 라이트 모드용 ThemeData 설정
/// - scaffoldBackgroundColor, primaryColor, appBarTheme 등 세부 설정 포함
ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: twitterGray100,
    primaryColor: twitterBlue,
    appBarTheme: AppBarTheme(
        backgroundColor: Colors.white, // 깔끔한 화이트 배경
        foregroundColor: twitterGray900, // 텍스트/아이콘은 진한 회색
        elevation: 0,
        titleTextStyle: TextStyle(
            color: twitterGray900,
            fontSize: 20,
            fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: twitterGray900),
    ),
    colorScheme: ColorScheme.light(
        primary: twitterBlue,
        onPrimary: Colors.white,
        secondary: twitterGray200,
        surface: Colors.white,
        background: twitterGray100,
        onBackground: twitterGray900,
        onSurface: twitterGray900,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: twitterBlue,
            foregroundColor: Colors.white,
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
            color: twitterGray900,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: twitterGray900),
    ),
    dividerColor: twitterGray200,
);