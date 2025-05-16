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
    if (token == null) return {'error': "로그인이 필요합니다."};

    final resp = await http.put(
      Uri.parse('${ApiConfig.host}${ApiConfig.api}/users/me/oshi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'screen_name': screenName}),
    );

    final data = jsonDecode(
        utf8.decode(resp.bodyBytes)      // ← 바이트 → UTF-8 String
    );
    if (resp.statusCode == 200) {
      return {'message': "오시가 ${data['oshi_screen_name']} 으로 설정되었습니다."};
    }

    if (resp.statusCode == 404 &&
        (data['detail']?.contains('찾을 수 없습니다') ?? false)) {
      return {'error': "존재하지 않는 트위터 유저입니다."};
    }
    return {'error': data['detail'] ?? "오시 등록에 문제가 발생했습니다."};
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