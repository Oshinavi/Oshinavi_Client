import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mediaproject/services/auth/auth_gate.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/tweet_provider.dart';
import 'package:mediaproject/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'package:mediaproject/viewmodels/schedule_view_model.dart';
import 'package:mediaproject/services/schedule_service.dart';

/// 전역 네비게이터 키
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 전역 ScaffoldMessenger 키 (필요시 전역에서 SnackBar 띄울 때 사용)
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// 전역 RouteObserver
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => OshiProvider()),
        ChangeNotifierProvider(create: (_) => TweetProvider()),
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
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
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