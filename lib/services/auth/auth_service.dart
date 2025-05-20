import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/dio_client.dart';

class AuthService {
  // 전역 DioClient 의 dio 인스턴스 사용
  final Dio _dio = DioClient().dio;
  Dio get dio => DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _signupPath   = '/api/auth/signup';
  static const String _loginPath    = '/api/auth/login';
  static const String _logoutPath   = '/api/auth/logout';
  static const String _tweetIdPath  = '/api/users/tweet_id';
  static const String _refreshPath  = '/api/auth/refresh';

  /// 회원가입
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String cfpassword,
    required String tweetId,
    required String ct0,
    required String authToken,
  }) async {
    try {
      final resp = await _dio.post(
        _signupPath,
        data: {
          'username'   : username,
          'email'      : email,
          'password'   : password,
          'cfpassword' : cfpassword,
          'tweet_id'   : tweetId,
          'ct0'        : ct0,
          'auth_token' : authToken,
        },
      );
      // 기존 resp.data 에 statusCode 추가
      final data = Map<String, dynamic>.from(resp.data as Map);
      data['statusCode'] = resp.statusCode;
      if (resp.statusCode == 201) {
        final token = data['access_token'] as String?;
        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
        }
      }
      return data;
    } on DioException catch (e) {
      return {
        'statusCode': e.response?.statusCode ?? 500,
        'error': e.response?.data['detail'] ?? '회원가입 실패',
      };
    }
  }

  /// 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final resp = await _dio.post(
        _loginPath,
        data: {'email': email, 'password': password},
      );
      final data = Map<String, dynamic>.from(resp.data as Map);
      data['statusCode'] = resp.statusCode;
      final token = data['access_token'] as String?;
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
      }
      return data;
    } on DioException catch (e) {
      return {
        'statusCode': e.response?.statusCode ?? 500,
        'error': '아이디 또는 비밀번호가 일치하지 않습니다.',
      };
    }
  }

  /// 로그아웃
  Future<Map<String, dynamic>> logout() async {
    final token = await _storage.read(key: 'jwt_token');
    // 로컬 토큰 삭제
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
    if (token == null) {
      return {'statusCode': 401, 'error': '로그인이 필요합니다.'};
    }
    try {
      final resp = await _dio.post(
        _logoutPath,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = Map<String, dynamic>.from(resp.data as Map);
      data['statusCode'] = resp.statusCode;
      return data;
    } on DioException catch (e) {
      return {
        'statusCode': e.response?.statusCode ?? 500,
        'error': '로그아웃 처리 중 오류가 발생했습니다.',
      };
    }
  }

  /// Twitter ID 조회
  Future<String?> getCurrentTweetId() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;
    try {
      final resp = await _dio.get(
        _tweetIdPath,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return resp.data['tweetId'] as String?;
    } on DioException {
      return null;
    }
  }

  /// Access token 재발급
  Future<bool> refreshAccessToken() async {
    try {
      final resp = await _dio.post(_refreshPath);
      final newToken = resp.data['access_token'] as String?;
      if (newToken != null) {
        await _storage.write(key: 'jwt_token', value: newToken);
        return true;
      }
    } on DioException {
      // 갱신 실패
    }
    return false;
  }
}