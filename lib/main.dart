import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mediaproject/pages/login_page.dart';
import 'package:mediaproject/pages/image_preview_page.dart';
import 'package:mediaproject/providers/user_profile_provider.dart';
import 'package:mediaproject/services/auth/auth_gate.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/tweet_provider.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'package:mediaproject/services/schedule_service.dart';
import 'package:mediaproject/viewmodels/schedule_view_model.dart';
import 'package:mediaproject/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 전역 네비게이터 키
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
/// 전역 ScaffoldMessenger 키
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
/// 전역 RouteObserver
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  // 1) Flutter 초기화 & 스플래시 보존
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // 2) 첫 프레임 렌더링 후, 잠시 딜레이를 준 뒤 스플래시 제거 & 페이드 인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => _opacity = 1);
        FlutterNativeSplash.remove();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 300),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        theme: themeProvider.themeData,
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
        routes: {
          ImagePreviewPage.routeName: (ctx) {
            final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, String>;
            return ImagePreviewPage(
              imageUrl: args['imageUrl']!,
              tag: args['tag']!,
            );
          },
        },
        home: const AuthGate(),
      ),
    );
  }
}