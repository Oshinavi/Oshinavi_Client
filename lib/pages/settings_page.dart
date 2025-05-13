// lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:mediaproject/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        title: Text(
          '환경설정',
          style: theme.textTheme.titleLarge
              ?.copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
      body: ListView(
        children: [
          // 섹션 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'GENERAL',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 다크모드 설정 타일
          Container(
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.brightness_6_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    '다크모드 설정',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onSurface),
                  ),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  horizontalTitleGap: 0,
                ),
                const Divider(indent: 16, endIndent: 16, height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}