import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediaproject/data/models/user_profile_model.dart';
import 'package:mediaproject/core/configs/api_config.dart';

/// 오시 관련 REST API 호출 클래스
/// - 오시 정보 조회, 등록/변경, 삭제
/// - 외부 트위터 사용자 프로필 조회
class OshiApi {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 1. 내 오시 정보 조회
  /// GET /users/me/oshi
  /// - JWT 토큰이 없으면 {'error': "로그인이 필요합니다."} 반환
  /// - 성공 시 { 'oshi_tweet_id': String, 'oshi_username': String }
  /// - 실패 시 { 'error': <detail 메시지> }
  Future<Map<String, dynamic>> getOshi() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return {'error': "로그인이 필요합니다."};

    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/users/me/oshi');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return {
        'oshi_tweet_id': data['oshi_screen_name'] as String,
        'oshi_username': data['oshi_username'] as String,
      };
    }
    return {'error': data['detail'] ?? "오시 정보를 불러오는 데 실패했습니다."};
  }

  /// 2. 오시 등록/변경
  /// PUT /users/me/oshi
  /// - body: { 'screen_name': screenName }
  /// - 성공 시 { 'message': '오시가 <screenName> 으로 설정되었습니다.' }
  /// - 실패 시 { 'error': <detail 또는 고정 메시지> }
  Future<Map<String, dynamic>> registerOshi(String screenName) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return {'error': '로그인이 필요합니다.'};

    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/users/me/oshi');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'screen_name': screenName}),
    );

    if (response.statusCode == 200) {
      try {
        final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return {
          'message': '오시가 ${data['oshi_screen_name']} 으로 설정되었습니다.'
        };
      } catch (_) {
        return {'error': '알 수 없는 응답을 받았습니다.'};
      }
    }
    return {'error': '존재하지 않는 유저입니다.'};
  }

  /// 2-1. 오시 삭제
  /// DELETE /users/me/oshi
  /// - 성공 시 HTTP 204, 실패 시 false 반환
  Future<bool> deleteOshi() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;

    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/users/me/oshi');
    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 204;
  }

  /// 3. 외부 트위터 사용자 프로필 조회
  /// GET /users/profile?tweet_id=<screenName>
  /// - 허용된 경우 UserProfileModel 반환, 아니면 null
  Future<UserProfileModel?> fetchUserProfile(String tweetId) async {
    final uri =
    Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/users/profile?tweet_id=$tweetId');
    final token = await _storage.read(key: 'jwt_token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return UserProfileModel.fromMap(data);
  }
}