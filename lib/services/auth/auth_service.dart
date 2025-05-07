import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Android 에뮬레이터 ↔ localhost 매핑
  final String _host = Platform.isAndroid
      ? 'http://10.0.2.2:8000'
      : 'http://127.0.0.1:8000';

  // 경로 상수
  static const String _signupPath   = '/api/auth/signup';
  static const String _loginPath    = '/api/auth/login';
  static const String _logoutPath   = '/api/auth/logout';
  static const String _tweetIdPath  = '/api/users/tweet_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 회원가입 처리
  /// - 성공 시 자동으로 로그인 후 { 'token': ... } 리턴
  /// - 에러 시 statusCode 와 error 메시지를 함께 리턴
  Future<Map<String, dynamic>> signup(
      String username,
      String email,
      String password,
      String cfpassword,
      String tweetId,
      ) async {
    final uri = Uri.parse('$_host$_signupPath');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username':   username,
        'email':      email,
        'password':   password,
        'cfpassword': cfpassword,
        'tweet_id':   tweetId,
      }),
    );

    if (resp.statusCode == 201) {
      // 자동 로그인
      return await login(email, password);
    }

    final body = jsonDecode(resp.body);
    final error = (body['detail'] ?? body['error'] ?? '회원가입에 실패했습니다.').toString();
    return {
      'statusCode': resp.statusCode,
      'error': error,
    };
  }

  /// 로그인 처리
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$_host$_loginPath');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final token = data['token'] as String?;
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
      }
      return data;
    } else {
      return {'error': '아이디 또는 비밀번호가 일치하지 않습니다.'};
    }
  }

  /// 로그아웃 처리
  Future<Map<String, dynamic>> logout() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      await http.post(
        Uri.parse('$_host$_logoutPath'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await _storage.delete(key: 'jwt_token');
      return {'message': '로그아웃 성공'};
    }
    return {'error': '로그인이 필요합니다.'};
  }

  /// 내 Twitter screen_name 조회
  Future<String?> getCurrentTweetId() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;
    final uri = Uri.parse('$_host$_tweetIdPath');
    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      return body['tweetId'] as String?;
    }
    return null;
  }
}