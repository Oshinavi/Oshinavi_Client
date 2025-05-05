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

/// 전역으로 사용할 RouteObserver 선언
final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 테마
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // 로컬 DB provider
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        // 오시(provider)
        ChangeNotifierProvider(create: (_) => OshiProvider()),
        // 트윗 자동 리플라이 provider
        ChangeNotifierProvider(create: (_) => TweetProvider()),
        // 스케줄 뷰모델
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
      navigatorObservers: [routeObserver],       // RouteObserver 연결
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [            // 한글 로컬라이제이션
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      theme: themeProvider.themeData,
      home: const AuthGate(),
    );
  }
}