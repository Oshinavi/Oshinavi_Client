import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediaproject/constants/api_config.dart';

class TweetService {
  static const _storage = FlutterSecureStorage();

  /// JWT 토큰을 꺼내서 헤더에 붙입니다.
  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --------------------------------------------------------------------------
  // 리플라이 전송
  // POST /tweets/reply/<tweetId>
  // --------------------------------------------------------------------------
  Future<bool> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/reply/$tweetId');
    final headers = await _authHeaders();

    Future<http.Response> _attempt() => http.post(
      uri,
      headers: headers,
      body: jsonEncode({'tweet_text': replyText}),
    );

    var resp = await _attempt();
    if (resp.statusCode == 500) {
      await Future.delayed(const Duration(milliseconds: 300));
      resp = await _attempt();
    }
    if (resp.statusCode != 200) return false;

    final body = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return body.containsKey('reply_tweet_id');
  }

  // --------------------------------------------------------------------------
  // 자동 리플라이 생성
  // POST /tweets/reply/auto_generate
  // --------------------------------------------------------------------------
  Future<String?> generateAutoReply(String tweetText) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/reply/auto_generate');
    final headers = await _authHeaders();

    final resp = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'tweet_text': tweetText}),
    );
    if (resp.statusCode != 200 ||
        !resp.headers['content-type']!.contains('application/json')) {
      print('❌ 자동 리플라이 실패 (${resp.statusCode}): ${resp.body}');
      return null;
    }

    final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return data['reply'] as String?;
  }
}