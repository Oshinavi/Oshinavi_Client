import 'package:flutter/material.dart';
import 'package:mediaproject/pages/login_page.dart';
import 'package:mediaproject/pages/register_page.dart';
import 'package:mediaproject/services/auth/auth_gate.dart';
import 'package:mediaproject/services/auth/login_or_register.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/themes/theme_provider.dart';
import 'package:provider/provider.dart';

import 'services/oshi_provider.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    MultiProvider(
        providers: [
          //theme provider
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          //database provider
          ChangeNotifierProvider(create: (context) => DatabaseProvider()),

          ChangeNotifierProvider(create: (_) => OshiProvider()),
        ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}