// services/reply_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TweetService {
  // Android ↔ localhost 매핑
  final String _baseHost = Platform.isAndroid
      ? 'http://10.0.2.2:5000'
      : 'http://127.0.0.1:5000';
  static const String _apiPrefix = '/api/tweets';

  /// tweetId 에 대해 replyText 를 POST
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
      // 1차 시도
      var resp = await attempt();

      // 500 에러면 1회 재시도
      if (resp.statusCode == 500) {
        await Future.delayed(const Duration(milliseconds: 300));
        resp = await attempt();
      }

      // JSON 아닌 경우 바로 실패 처리
      if (resp.headers['content-type']?.contains('application/json') != true) {
        print('🚨 비JSON 응답 ${resp.statusCode}: ${resp.body}');
        return false;
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;

      if (resp.statusCode == 200 && body['success'] == true) {
        print('✅ 리플라이 성공');
        return true;
      } else {
        final err = body['error'] ?? body['message'] ?? '알 수 없는 오류';
        print('❌ 리플라이 실패 (${resp.statusCode}): $err');
        return false;
      }
    } catch (e) {
      print('❌ 예외 발생 in sendReply: $e');
      return false;
    }
  }

  /// 자동 생성된 리플라이 텍스트 가져오기
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
      return data['reply'] as String? ?? '（자동 답변 생성에 실패했습니다）';
    } catch (e) {
      print('❌ 예외 발생 in generateAutoReply: $e');
      return null;
    }
  }
}