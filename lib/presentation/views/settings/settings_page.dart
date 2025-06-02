import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../themes/theme_provider.dart';

/// SettingsPage:
/// - 앱 환경설정 화면
/// 주요 단계:
/// 1) ThemeProvider를 통해 isDarkMode 가져오기
/// 2) AppBar에 '환경설정' 타이틀 표시
/// 3) 'GENERAL' 섹션 레이블 표시
/// 4) 다크모드 토글 Card/ListTile 표시 → Switch onChanged 호출 시 ThemeProvider.toggleTheme()
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    final titleTextColor = Theme.of(context).colorScheme.onSurface;
    final sectionLabelColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '환경설정',
          style: TextStyle(color: titleTextColor),
        ),
        iconTheme: IconThemeData(color: titleTextColor),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3) 'GENERAL' 섹션 레이블
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'GENERAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sectionLabelColor,
                  ),
                ),
              ),

              // 4) 다크 모드 토글 Card/ListTile
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    '다크모드 설정',
                    style: TextStyle(
                      fontSize: 16,
                      color: titleTextColor,
                    ),
                  ),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (v) {
                      themeProvider.toggleTheme(); // 테마 토글
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ""TODO"" 여기에 나중에 기능 추가할것
            ],
          ),
        ),
      ),
    );
  }
}