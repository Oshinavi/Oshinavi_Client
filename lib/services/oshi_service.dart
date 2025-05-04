import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mediaproject/models/user.dart';

class OshiService {
  static const _prefix = '/api/users';
  final String baseUrl = 'http://127.0.0.1:5000';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 오시 정보 조회
  Future<Map<String, dynamic>> getOshi() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      return {'error': "로그인이 필요합니다."};
    }

    final resp = await http.get(
      Uri.parse('$baseUrl$_prefix/oshi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = json.decode(resp.body);
    if (resp.statusCode == 200) {
      return {
        'oshi_tweet_id': data['oshi_tweet_id'],
        'oshi_username': data['oshi_username'],
      };
    }

    // 백엔드가 한글 에러 메시지를 내려줍니다.
    return {
      'error': data['error'] ?? "오시 정보를 불러오는 데 실패했습니다."
    };
  }

  /// 오시 등록
  Future<Map<String, dynamic>> registerOshi(String oshiTweetId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      return {'error': "로그인이 필요합니다."};
    }

    final resp = await http.post(
      Uri.parse('$baseUrl$_prefix/oshi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'oshi_tweet_id': oshiTweetId}),
    );

    final data = json.decode(resp.body);
    if (resp.statusCode == 200) {
      return {'message': data['message']};
    }
    // 한글 메시지 기준으로 에러 처리
    if (resp.statusCode == 404 &&
        (data['error']?.contains('찾을 수 없습니다') ?? false)) {
      return {'error': "존재하지 않는 유저입니다."};
    }
    return {'error': data['error'] ?? "오시 등록에 문제가 발생했습니다."};
  }

  /// 외부 트위터 유저 프로필 조회
  Future<UserProfile?> getUserProfile(String tweetId) async {
    final resp = await http.get(
      Uri.parse('$baseUrl$_prefix?tweet_id=$tweetId'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = json.decode(resp.body);
    if (resp.statusCode == 200) {
      return UserProfile.fromMap(data);
    } else {
      print('⚠️ 서버 응답 오류: ${data['error']}');
      return null;
    }
  }
}