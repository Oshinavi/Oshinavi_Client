import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mediaproject/components/setting_tile.dart';
import 'package:mediaproject/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
/*

다크모드 설정
계정 설정

 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        title: Text("환경설정"),
         foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: Column(
        children: [
          //다크모드 설정
          SettingsTile(
            title: "다크모드 설정",
            action: CupertinoSwitch(
              value: Provider.of<ThemeProvider>(context, listen: true).isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),


          )
        ],
      )
    );
  }
}
