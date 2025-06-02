import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/configs/api_config.dart';
import '../../presentation/utils/custom_exceptions.dart';

/// 인증 관련 REST API 호출 클래스
/// - 로그인/회원가입/로그아웃/토큰 갱신/현재 Twitter ID 조회 기능 제공
class AuthApi {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 이메일/비밀번호 로그인
  /// - 성공 시 JWT 토큰을 secure storage에 저장
  /// - 반환: { "access_token": "...", "statusCode": 200, ... } 또는 error 정보
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
      }
      data['statusCode'] = response.statusCode;
      return data;
    } else {
      final decoded = response.body.isNotEmpty
          ? (jsonDecode(response.body) as Map<String, dynamic>)['detail']
          : '로그인 실패';
      return {
        'statusCode': response.statusCode,
        'error': decoded ?? '로그인 실패',
      };
    }
  }

  /// 회원가입
  /// - request body에 username, email, password, cfpassword, tweet_id, ct0, auth_token 포함
  /// - 성공 시 JWT 토큰을 secure storage에 저장
  /// - 반환: { "access_token": "...", "statusCode": 201, ... } 또는 error 정보
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String cfpassword,
    required String tweetId,
    required String ct0,
    required String authToken,
  }) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/auth/signup');
    final body = json.encode({
      'username': username,
      'email': email,
      'password': password,
      'cfpassword': cfpassword,
      'tweet_id': tweetId,
      'ct0': ct0,
      'auth_token': authToken,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
      }
      data['statusCode'] = response.statusCode;
      return data;
    } else {
      final decoded = response.body.isNotEmpty
          ? (jsonDecode(response.body) as Map<String, dynamic>)['detail']
          : '회원가입 실패';
      return {
        'statusCode': response.statusCode,
        'error': decoded ?? '회원가입 실패',
      };
    }
  }

  /// 로그아웃
  /// - secure storage에서 token을 읽어 Authorization 헤더로 전달
  /// - 성공 시 local storage의 jwt_token, refresh_token 삭제
  Future<void> logout() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      throw UnauthorizedException('로그인이 필요합니다.');
    }
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/auth/logout');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw NetworkException('로그아웃 실패 (status=${response.statusCode})');
    }
    // 토큰 삭제
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
  }

  /// 토큰 재발급
  /// - refresh endpoint를 호출하여 새로운 access_token 저장
  /// - 성공 시 true 실패 시 false 반환
  Future<bool> refreshToken() async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/auth/refresh');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final newToken =
      (jsonDecode(response.body) as Map<String, dynamic>)['access_token']
      as String?;
      if (newToken != null) {
        await _storage.write(key: 'jwt_token', value: newToken);
        return true;
      }
    }
    return false;
  }

  /// 현재 로그인된 사용자의 Twitter ID(스크린네임) 조회
  /// - Authorization 헤더에 JWT 포함하여 GET /users/tweet_id 호출
  Future<String?> fetchCurrentTweetId() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/users/tweet_id');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['tweetId'] as String?;
    }
    return null;
  }
}