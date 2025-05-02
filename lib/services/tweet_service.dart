// services/reply_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TweetService {
  final String baseUrl = 'http://127.0.0.1:5000';

  Future<bool> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    Future<http.Response> attemptSend() {
      return http.post(
        Uri.parse('$baseUrl/api/tweets/reply/$tweetId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"tweet_text": replyText}),
      );
    }

    try {
      // 첫 번째 시도
      http.Response response = await attemptSend();

      // 만약 500 에러라면 재시도
      if (response.statusCode == 500) {
        print("🔁 서버 오류(500), 재시도 중...");
        await Future.delayed(const Duration(milliseconds: 500));
        response = await attemptSend();

        if (response.statusCode == 200) {
          print("✅ 재시도 성공");
          return true;
        } else {
          print("❌ 재시도 실패: ${response.statusCode}");
          final errorMsg = jsonDecode(response.body)['error'];
          print("에러 메시지: $errorMsg");
          return false;
        }
      }

      // 최초 요청이 성공했을 경우
      if (response.statusCode == 200) {
        print("✅ 리플라이 성공");
        return true;
      } else {
        final errorMsg = jsonDecode(response.body)['error'];
        print("❌ 리플라이 실패: $errorMsg");
        return false;
      }
    } catch (e) {
      print("❌ 예외 발생: $e");
      return false;
    }
  }


  Future<String?> generateAutoReply(String tweetText) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/tweets/reply/auto_generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tweet_text': tweetText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // generated_reply가 직접 문자열로 오는 경우
        if (data is String) return data;
        // {"reply": "..."} 형태로 오는 경우 처리
        return data['reply'] ?? '（자동 답변 생성에 실패했습니다.）';
      } else {
        final errorMsg = jsonDecode(response.body)['error'];
        print('자동 리플라이 실패: $errorMsg');
        return null;
      }
    } catch (e) {
      print('예외 발생 (자동 리플): $e');
      return null;
    }
  }
}