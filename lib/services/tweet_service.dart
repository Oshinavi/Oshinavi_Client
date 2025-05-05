// lib/services/tweet_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TweetService {
  final String _baseHost = Platform.isAndroid
      ? 'http://10.0.2.2:5000'
      : 'http://127.0.0.1:5000';
  static const String _apiPrefix = '/api/tweets';

  Future<bool> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final uri = Uri.parse('$_baseHost$_apiPrefix/reply/$tweetId');
    Future<http.Response> attempt() => http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'tweet_text': replyText}),
    );

    try {
      var resp = await attempt();
      if (resp.statusCode == 500) {
        await Future.delayed(const Duration(milliseconds: 300));
        resp = await attempt();
      }
      if (resp.headers['content-type']?.contains('application/json') != true) {
        print('🚨 비JSON 응답 ${resp.statusCode}: ${resp.body}');
        return false;
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return resp.statusCode == 200 && body['success'] == true;
    } catch (e) {
      print('❌ sendReply 예외: $e');
      return false;
    }
  }

  Future<String?> generateAutoReply(String tweetText) async {
    final uri = Uri.parse('$_baseHost$_apiPrefix/reply/auto_generate');
    try {
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tweet_text': tweetText}),
      );
      if (resp.statusCode != 200 ||
          resp.headers['content-type']?.contains('application/json') != true) {
        print('❌ 자동 리플라이 실패 (${resp.statusCode}): ${resp.body}');
        return null;
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['reply'] as String?;
    } catch (e) {
      print('❌ generateAutoReply 예외: $e');
      return null;
    }
  }
}