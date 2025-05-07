import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediaproject/constants/api_config.dart';

class TweetService {
  // --------------------------------------------------------------------------
  // 리플라이 전송
  // POST /reply/<tweetId>
  // --------------------------------------------------------------------------
  Future<bool> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final uri =
    Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/reply/$tweetId');

    Future<http.Response> _attempt() => http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'tweet_text': replyText}),
    );

    var resp = await _attempt();
    if (resp.statusCode == 500) {
      await Future.delayed(const Duration(milliseconds: 300));
      resp = await _attempt();
    }

    if (resp.statusCode != 200) return false;
    if (!resp.headers['content-type']!.contains('application/json')) return false;

    final body = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return body['success'] == true;
  }

  // --------------------------------------------------------------------------
  // 자동 리플라이 생성
  // POST /reply/auto_generate
  // --------------------------------------------------------------------------
  Future<String?> generateAutoReply(String tweetText) async {
    final uri = Uri.parse(
        '${ApiConfig.host}${ApiConfig.api}/tweets/reply/auto_generate'
    );

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
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