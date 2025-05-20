import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mediaproject/models/user_profile.dart';
import 'package:mediaproject/constants/api_config.dart';

class OshiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ==========================================================================
  // 1. 오시 정보 조회  (GET /users/me/oshi)
  // ==========================================================================
  Future<Map<String, dynamic>> getOshi() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return {'error': "로그인이 필요합니다."};

    final resp = await http.get(
      Uri.parse('${ApiConfig.host}${ApiConfig.api}/users/me/oshi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(utf8.decode(resp.bodyBytes));
    if (resp.statusCode == 200) {
      return {
        'oshi_tweet_id': data['oshi_screen_name'] as String,
        'oshi_username': data['oshi_username']   as String,
      };
    }
    return {'error': data['detail'] ?? "오시 정보를 불러오는 데 실패했습니다."};
  }

  // ==========================================================================
  // 2. 오시 등록/변경  (PUT /users/me/oshi)
  // ==========================================================================
  Future<Map<String, dynamic>> registerOshi(String screenName) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return {'error': '로그인이 필요합니다.'};

    final resp = await http.put(
      Uri.parse('${ApiConfig.host}${ApiConfig.api}/users/me/oshi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'screen_name': screenName}),
    );

    // 1) 성공(200)일 때만 파싱
    if (resp.statusCode == 200) {
      try {
        final body = utf8.decode(resp.bodyBytes);
        final data = jsonDecode(body) as Map<String, dynamic>;
        return {
          'message': '오시가 ${data['oshi_screen_name']} 으로 설정되었습니다.'
        };
      } catch (e) {
        // JSON 파싱 에러도 안전하게 처리
        print('registerOshi: JSON parsing failed $e');
        return {'error': '알 수 없는 응답을 받았습니다.'};
      }
    }

    // 2) 그 외 상태코드는 절대 jsonDecode 하지 않고 에러로 처리
    print('registerOshi failed: status=${resp.statusCode}, body="${resp.body}"');
    return {'error': '존재하지 않는 유저입니다.'};
  }

  // --------------------------------------------------------------------------
  // 2-1. 오시 삭제  (DELETE /users/me/oshi)
  // --------------------------------------------------------------------------
  Future<bool> deleteOshi() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;

    final resp = await http.delete(
      Uri.parse('${ApiConfig.host}${ApiConfig.api}/users/me/oshi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return resp.statusCode == 204;
  }

  // ==========================================================================
  // 3. 외부 트위터 유저 프로필 조회
  // ==========================================================================
  Future<UserProfile?> getUserProfile(String tweetId) async {
    final uri = Uri.parse(
        '${ApiConfig.host}${ApiConfig.api}/users/profile?tweet_id=$tweetId');

    final token = await _storage.read(key: 'jwt_token');
    final headers = <String,String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    // final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) {
      print('⚠️ 서버 응답 오류: ${resp.body}');
      return null;
    }
    return UserProfile.fromMap(jsonDecode(utf8.decode(resp.bodyBytes)));
  }
}