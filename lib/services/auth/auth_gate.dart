  import 'package:flutter/material.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import 'package:mediaproject/pages/home_page.dart';
  import 'package:mediaproject/services/auth/login_or_register.dart';
  import 'package:mediaproject/services/auth/auth_service.dart';
  import 'package:dio/dio.dart';

  class AuthGate extends StatefulWidget {
    const AuthGate({Key? key}) : super(key: key);

    @override
    State<AuthGate> createState() => _AuthGateState();
  }

  class _AuthGateState extends State<AuthGate> {
    final _authService = AuthService();
    final _storage     = const FlutterSecureStorage();
    bool? _loggedIn;

    @override
    void initState() {
      super.initState();
      _checkLoginStatus();
    }

    Future<void> _checkLoginStatus() async {
      final jwt = await _storage.read(key: 'jwt_token');
      if (jwt == null) {
        setState(() => _loggedIn = false);
        return;
      }

      try {
        final resp = await _authService.dio.get(
          '/api/auth/check_login',
          options: Options(headers: {'Authorization': 'Bearer $jwt'}),
        );
        setState(() => _loggedIn = resp.statusCode == 200);
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          final refresh = await _storage.read(key: 'refresh_token');
          if (refresh == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("세션이 만료되었습니다. 다시 로그인해주세요."),
                duration: Duration(seconds: 2),
              ),
            );
            setState(() => _loggedIn = false);
            return;
          }

          final ok = await _authService.refreshAccessToken();
          if (!ok) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("세션 갱신에 실패했습니다. 다시 로그인해주세요."),
                duration: Duration(seconds: 2),
              ),
            );
            setState(() => _loggedIn = false);
            return;
          }

          final newJwt = await _storage.read(key: 'jwt_token');
          final retry = await _authService.dio.get(
            '/api/auth/check_login',
            options: Options(headers: {'Authorization': 'Bearer $newJwt'}),
          );
          setState(() => _loggedIn = retry.statusCode == 200);
        } else {
          setState(() => _loggedIn = false);
        }
      } catch (_) {
        setState(() => _loggedIn = false);
      }
    }

    @override
    Widget build(BuildContext context) {
      // 아직 상태가 결정되지 않았으면 로딩 화면
      if (_loggedIn == null) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // 로그인 성공 시
      if (_loggedIn == true) {
        return const HomePage();
      }

      // 로그인 필요 시
      return Scaffold(
        body: const LoginOrRegister(),
      );
    }
  }