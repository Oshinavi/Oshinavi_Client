import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/configs/api_config.dart';
import '../../presentation/utils/custom_exceptions.dart';
import '../models/reply_model.dart';

/// 트윗 관련 REST API 호출 클래스
/// - 리플 전송, 조회, 자동 생성, 메타데이터 조회, 리플 삭제
class TweetApi {
  static final String _baseUrl = '${ApiConfig.host}${ApiConfig.apiBase}/tweets';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// JWT 토큰을 포함한 HTTP 헤더 반환
  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 리플 전송 (POST /tweets/reply/{tweetId})
  /// - retry: HTTP 500 발생 시 한 번 더 재시도
  /// - HTTP 200: ReplyModel 반환
  /// - 오류 발생 시 상태 코드별 예외 던짐
  Future<ReplyModel> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final uri = Uri.parse('$_baseUrl/reply/$tweetId');
    final headers = await _authHeaders();

    Future<http.Response> _attempt() => http.post(
      uri,
      headers: headers,
      body: jsonEncode({'tweet_text': replyText}),
    );

    var response = await _attempt();
    if (response.statusCode == 500) {
      // 서버 오류 시 잠시 대기 후 한 번 더 재시도
      await Future.delayed(const Duration(milliseconds: 300));
      response = await _attempt();
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ReplyModel.fromMap(data);
    }

    // 상태 코드별 커스텀 예외 던짐
    final detail = _extractDetail(response);
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(detail);
      case 401:
        throw UnauthorizedException(detail);
      case 404:
        throw NotFoundException(detail);
      case 409:
        throw ConflictException(detail);
      default:
        throw NetworkException("리플라이 전송 실패 (${response.statusCode})");
    }
  }

  /// 리플 목록 조회 (GET /tweets/{tweetId}/replies)
  /// - HTTP 200: List<ReplyModel> 반환
  /// - 오류 발생 시 상태 코드별 예외 던짐
  Future<List<ReplyModel>> fetchReplies({required String tweetId}) async {
    final uri = Uri.parse('$_baseUrl/$tweetId/replies');
    final headers = await _authHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((m) => ReplyModel.fromMap(m as Map<String, dynamic>))
          .toList();
    }

    final detail = _extractDetail(response);
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(detail);
      case 401:
        throw UnauthorizedException(detail);
      case 404:
        throw NotFoundException(detail);
      default:
        throw NetworkException("리플 목록 로드 실패 (${response.statusCode})");
    }
  }

  /// 자동 리플라이 생성 (POST /tweets/{tweetId}/reply/auto_generate)
  /// - HTTP 200 + JSON 반환: 자동 생성된 리플라이 문자열 반환
  /// - 실패 시 null 반환
  Future<String?> generateAutoReply({
    required String tweetId,
    required String tweetText,
    required List<String> contexts,
  }) async {
    final uri = Uri.parse('$_baseUrl/$tweetId/reply/auto_generate');
    final headers = await _authHeaders();
    final body = jsonEncode({'tweet_text': tweetText, 'contexts': contexts});

    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200 &&
        response.headers['content-type']?.contains('application/json') == true) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] as String?;
    }
    // 자동 리플라이가 필수가 아니므로 실패 시 null 반환
    return null;
  }

  /// 트윗 메타데이터 조회 (GET /tweets/{tweetId}/metadata)
  /// - HTTP 200: Map<String, dynamic> 반환
  /// - 오류 발생 시 상태 코드별 예외 던짐
  Future<Map<String, dynamic>> fetchTweetMetadata({required String tweetId}) async {
    final uri = Uri.parse('$_baseUrl/$tweetId/metadata');
    final headers = await _authHeaders();
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final detail = _extractDetail(response);
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(detail);
      case 401:
        throw UnauthorizedException(detail);
      case 404:
        throw NotFoundException(detail);
      default:
        throw NetworkException("메타데이터 로드 실패 (${response.statusCode})");
    }
  }

  /// 리플 삭제 (DELETE /tweets/reply/{replyId})
  /// - HTTP 200 or 204: 정상 처리
  /// - 오류 발생 시 상태 코드별 예외 던짐
  Future<void> deleteReply({required String replyId}) async {
    final uri = Uri.parse('$_baseUrl/reply/$replyId');
    final headers = await _authHeaders();
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final detail = _extractDetail(response);
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(detail);
      case 401:
        throw UnauthorizedException(detail);
      case 404:
        throw NotFoundException(detail);
      default:
        throw NetworkException("리플라이 삭제 실패 (${response.statusCode})");
    }
  }

  /// HTTP 응답 body에서 '{"detail": "..."}' 형태로 내려온 'detail' 값을 추출하는 헬퍼
  String _extractDetail(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return (body['detail'] as String?) ?? '알 수 없는 오류';
    } catch (_) {
      return '알 수 없는 오류';
    }
  }
}