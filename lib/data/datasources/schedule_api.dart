import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../core/configs/api_config.dart';
import '../models/schedule_model.dart';
import '../../core/exceptions/api_exception.dart';

/// 스케줄 관련 REST API 호출 클래스
/// - 내 스케줄 조회 (GET)
/// - 생성 (POST)
/// - 수정 (PUT)
/// - 삭제 (DELETE)
class ScheduleApi {
  static final String _baseUrl = '${ApiConfig.host}${ApiConfig.apiBase}/schedules';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _client;

  ScheduleApi({http.Client? client}) : _client = client ?? http.Client();

  /// JWT 토큰을 포함한 HTTP 헤더 생성
  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// ▶ 내 스케줄 목록 조회 (GET /schedules)
  /// - HTTP 200: List<ScheduleModel> 반환
  /// - HTTP 오류 시 상태 코드별 예외 던짐
  Future<List<ScheduleModel>> fetchMySchedules() async {
    final uri = Uri.parse(_baseUrl);
    final response = await _client.get(uri, headers: await _authHeaders());

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(utf8Body) as List<dynamic>;
      return jsonList
          .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 오류 시 { "detail": "..." } 형태로 메시지를 파싱 후, 상태 코드별 예외 던짐
    final utf8Body = utf8.decode(response.bodyBytes);
    final Map<String, dynamic> errJson = jsonDecode(utf8Body) as Map<String, dynamic>;
    final detailMessage = errJson['detail'] as String? ?? '알 수 없는 오류가 발생했습니다.';

    switch (response.statusCode) {
      case 400:
        throw BadRequestException(detailMessage);
      case 401:
        throw UnauthorizedException(detailMessage);
      case 404:
        throw NotFoundException(detailMessage);
      case 409:
        throw ConflictException(detailMessage);
      default:
        throw ServerException(detailMessage);
    }
  }

  /// 새 스케줄 생성 (POST /schedules)
  /// - HTTP 201: 생성된 ScheduleModel 반환
  /// - HTTP 오류 시 두 번까지 재시도 후 상태 코드별 예외 던짐
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final uri = Uri.parse(_baseUrl);

    for (int attempt = 0; attempt < 2; attempt++) {
      final response = await _client.post(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(schedule.toJson()),
      );

      if (response.statusCode == 201) {
        final utf8Body = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> json = jsonDecode(utf8Body) as Map<String, dynamic>;
        return ScheduleModel.fromJson(json);
      }

      // 오류 시 메시지 파싱
      final utf8Body = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> errJson = jsonDecode(utf8Body) as Map<String, dynamic>;
      final detailMessage = errJson['detail'] as String? ?? '알 수 없는 오류';

      switch (response.statusCode) {
        case 400:
          throw BadRequestException(detailMessage);
        case 401:
          throw UnauthorizedException(detailMessage);
        case 404:
          throw NotFoundException(detailMessage);
        case 409:
          throw ConflictException(detailMessage);
        default:
          throw ServerException(detailMessage);
      }
    }

    // 두 번 시도해도 생성되지 않으면 서버 예외
    throw ServerException('스케줄 생성 중 알 수 없는 오류가 발생했습니다.');
  }

  /// 스케줄 수정 (PUT /schedules/{id})
  /// - HTTP 200: 수정된 ScheduleModel 반환
  /// - HTTP 오류 시 두 번까지 재시도 후 상태 코드별 예외 던짐
  Future<ScheduleModel> updateSchedule(int id, Map<String, dynamic> changes) async {
    final uri = Uri.parse('$_baseUrl/$id');

    for (int attempt = 0; attempt < 2; attempt++) {
      final response = await _client.put(
        uri,
        headers: await _authHeaders(),
        body: jsonEncode(changes),
      );

      if (response.statusCode == 200) {
        final utf8Body = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> json = jsonDecode(utf8Body) as Map<String, dynamic>;
        return ScheduleModel.fromJson(json);
      }

      // 오류 시 메시지 파싱
      final utf8Body = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> errJson = jsonDecode(utf8Body) as Map<String, dynamic>;
      final detailMessage = errJson['detail'] as String? ?? '알 수 없는 오류';

      switch (response.statusCode) {
        case 400:
          throw BadRequestException(detailMessage);
        case 401:
          throw UnauthorizedException(detailMessage);
        case 404:
          throw NotFoundException(detailMessage);
        case 409:
          throw ConflictException(detailMessage);
        default:
          throw ServerException(detailMessage);
      }
    }

    throw ServerException('스케줄 수정 중 알 수 없는 오류가 발생했습니다.');
  }

  /// 스케줄 삭제 (DELETE /schedules/{id})
  /// - HTTP 200: 정상 삭제
  /// - HTTP 오류 시 두 번까지 재시도 후 상태 코드별 예외 던짐
  Future<void> deleteSchedule(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');

    for (int attempt = 0; attempt < 2; attempt++) {
      final response = await _client.delete(uri, headers: await _authHeaders());
      if (response.statusCode == 200) return;

      // 오류 시 메시지 파싱
      final utf8Body = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> errJson = jsonDecode(utf8Body) as Map<String, dynamic>;
      final detailMessage = errJson['detail'] as String? ?? '알 수 없는 오류';

      switch (response.statusCode) {
        case 400:
          throw BadRequestException(detailMessage);
        case 401:
          throw UnauthorizedException(detailMessage);
        case 404:
          throw NotFoundException(detailMessage);
        case 409:
          throw ConflictException(detailMessage);
        default:
          throw ServerException(detailMessage);
      }
    }

    throw ServerException('스케줄 삭제 중 알 수 없는 오류가 발생했습니다.');
  }
}