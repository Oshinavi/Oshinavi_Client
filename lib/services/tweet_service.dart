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
  Future<Map<String, dynamic>> sendReply({
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
    if (resp.statusCode != 200) {
      throw Exception('리플라이 전송 실패 (${resp.statusCode})');
    }
    // 백엔드가 ReplyResponse 구조로 내려주는 전체 맵 반환
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// 기존: 자동 리플라이 생성
  Future<String?> generateAutoReply({
    required String tweetId,
    required String tweetText,
    required List<String> contexts,
  }) async {
    final uri = Uri.parse(
        '${ApiConfig.host}${ApiConfig.api}/tweets/$tweetId/reply/auto_generate'
    );
    final headers = await _authHeaders();

    final body = jsonEncode({
      'tweet_text': tweetText,
      'contexts': contexts,
    });

    final resp = await http.post(uri, headers: headers, body: body);
    if (resp.statusCode != 200 ||
        !(resp.headers['content-type'] ?? '').contains('application/json')) {
      return null;
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['reply'] as String?;
  }

  Future<void> deleteReply({
    required String replyId,
  }) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/reply/$replyId');
    final headers = await _authHeaders();

    final resp = await http.delete(uri, headers: headers);
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('리플라이 삭제 실패 (${resp.statusCode})');
    }
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
  Future<List<Map<String, dynamic>>> fetchReplies({
    required String tweetId,
  }) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/$tweetId/replies');
    final headers = await _authHeaders();
    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode != 200) {
      throw Exception('리플 목록 로드 실패 (${resp.statusCode})');
    }
    return List<Map<String, dynamic>>.from(jsonDecode(resp.body));
  }
}