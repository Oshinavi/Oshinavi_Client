import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Android 에뮬레이터 ↔ localhost 매핑
  final String _host = Platform.isAndroid
      ? 'http://10.0.2.2:5000'
      : 'http://127.0.0.1:5000';

  // 경로 상수
  static const _loginPath    = '/api/login';
  static const _signupPath   = '/api/signup';
  static const _logoutPath   = '/api/logout';
  static const _tweetIdPath  = '/api/users/tweet_id';

  String? _token;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$_host$_loginPath');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _token = data['token'];
        await FlutterSecureStorage().write(key: 'jwt_token', value: _token);
        print('Token received: $_token');
        return data;
      } else {
        return {'error': '아이디 또는 비밀번호가 일치하지 않습니다.'};
      }
    } catch (e) {
      return {'error': '네트워크 에러: $e'};
    }
  }

  Future<Map<String, dynamic>> signup(
      String username,
      String email,
      String password,
      String cfpassword,
      String tweetId) async {
    if (password != cfpassword) {
      return {'error': '입력한 비밀번호가 일치하지 않습니다.'};
    }

    final uri = Uri.parse('$_host$_signupPath');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'cfpassword': cfpassword,
          'tweet_id': tweetId,
        }),
      );

      if (resp.statusCode == 201) {
        // 가입 성공 → 자동 로그인
        return await login(email, password);
      } else {
        final err = jsonDecode(resp.body)['error'];
        return {'error': err ?? '회원가입에 실패했습니다.'};
      }
    } catch (e) {
      return {'error': '네트워크 에러: $e'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final storage = FlutterSecureStorage();
    _token ??= await storage.read(key: 'jwt_token');

    if (_token == null) {
      return {'error': '로그인이 필요합니다.'};
    }

    final uri = Uri.parse('$_host$_logoutPath');
    try {
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      _token = null;
      await storage.delete(key: 'jwt_token');
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      } else {
        return {'error': '로그아웃 실패 (${resp.statusCode})'};
      }
    } catch (e) {
      _token = null;
      await storage.delete(key: 'jwt_token');
      return {'error': '네트워크 에러: $e'};
    }
  }

  Future<String?> getCurrentTweetId() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      print("JWT 토큰 없음");
      return null;
    }

    final uri = Uri.parse('$_host$_tweetIdPath');
    try {
      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final body = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        return body['tweetId'] as String?;
      } else {
        print('Error ${resp.statusCode}: ${body['error']}');
        return null;
      }
    } catch (e) {
      print("네트워크 에러: $e");
      return null;
    }
  }
}