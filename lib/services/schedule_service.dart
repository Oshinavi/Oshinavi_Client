import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/schedule.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ScheduleService {
  static const _baseUrl = 'http://127.0.0.1:8000/api/schedules';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _client;

  ScheduleService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> get _token async => await _storage.read(key: 'jwt_token');

  Future<Map<String, String>> _headers() async {
    final token = await _token;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// 내 스케줄 목록 조회
  Future<List<Schedule>> fetchMySchedules() async {
    final resp = await _client.get(
      Uri.parse(_baseUrl),
      headers: await _headers(),
    );
    if (resp.statusCode == 200) {
      final js = jsonDecode(utf8.decode(resp.bodyBytes)) as List<dynamic>;
      return js.map((e) => Schedule.fromJson(e)).toList();
    } else {
      throw ApiException(resp.statusCode, '스케줄 조회 실패: ${resp.body}');
    }
  }

  /// 새 스케줄 생성
  Future<Schedule> createSchedule(Schedule s) async {
    ApiException? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      final resp = await _client.post(
        Uri.parse(_baseUrl),
        headers: await _headers(),
        body: jsonEncode(s.toJson()),
      );
      if (resp.statusCode == 201) {
        return Schedule.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      } else {
        lastError = ApiException(resp.statusCode, '스케줄 생성 실패: ${resp.body}');
      }
    }
    throw lastError!;
  }

  /// 스케줄 수정
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> changes) async {
    ApiException? lastError;
    final uri = Uri.parse('$_baseUrl/$id');
    for (var attempt = 0; attempt < 2; attempt++) {
      final resp = await _client.put(
        uri,
        headers: await _headers(),
        body: jsonEncode(changes),
      );
      if (resp.statusCode == 200) {
        return Schedule.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      } else {
        lastError = ApiException(resp.statusCode, '스케줄 수정 실패: ${resp.body}');
      }
    }
    throw lastError!;
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(int id) async {
    ApiException? lastError;
    final uri = Uri.parse('$_baseUrl/$id');
    for (var attempt = 0; attempt < 2; attempt++) {
      final resp = await _client.delete(
        uri,
        headers: await _headers(),
      );
      if (resp.statusCode == 200) {
        return;
      } else {
        lastError = ApiException(resp.statusCode, '스케줄 삭제 실패: ${resp.body}');
      }
    }
    throw lastError!;
  }
}