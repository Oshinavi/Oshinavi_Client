import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mediaproject/services/auth/auth_gate.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/tweet_provider.dart';
import 'package:mediaproject/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'services/oshi_provider.dart';
import 'package:mediaproject/viewmodels/schedule_view_model.dart';
import 'package:mediaproject/services/schedule_service.dart';


final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        // theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // database provider
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => OshiProvider()),
        ChangeNotifierProvider(create: (_) => TweetProvider()),

        // ScheduleViewModel
        ChangeNotifierProvider(
          create: (_) => ScheduleViewModel(api: ScheduleService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,

      // ↓↓↓ 로컬라이제이션 추가 ↓↓↓
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어
        Locale('en', 'US'), // 영어
      ],
      locale: const Locale('ko', 'KR'),
      // ↑↑↑ 로컬라이제이션 추가 ↑↑↑

      theme: themeProvider.themeData,
      home: const AuthGate(),
    );
  }
}