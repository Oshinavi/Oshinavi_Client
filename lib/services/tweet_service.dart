import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediaproject/constants/api_config.dart';

class TweetService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 기존: 리플라이 전송
  Future<bool> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/reply/$tweetId');
    final headers = await _authHeaders();

    Future<http.Response> attempt() => http.post(
      uri,
      headers: headers,
      body: jsonEncode({'tweet_text': replyText}),
    );

    var resp = await attempt();
    if (resp.statusCode == 500) {
      // 1회 재시도
      await Future.delayed(const Duration(milliseconds: 300));
      resp = await attempt();
    }
    if (resp.statusCode != 200) return false;

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return body.containsKey('reply_tweet_id');
  }

  /// 기존: 자동 리플라이 생성
  Future<String?> generateAutoReply(String tweetText) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/reply/auto_generate');
    final headers = await _authHeaders();

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'tweet_text': tweetText}),
    );
    if (resp.statusCode != 200 ||
        !(resp.headers['content-type'] ?? '').contains('application/json')) {
      return null;
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['reply'] as String?;
  }

  /// 신규: 분류·일정 메타데이터 조회
  Future<Map<String, dynamic>> fetchTweetMetadata({
    required String tweetId,
  }) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/$tweetId/metadata');
    final headers = await _authHeaders();
    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('메타데이터 로드 실패 (${resp.statusCode})');
    }
  }
}