import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/schedule.dart';

/// API 호출 중에 던져지는 예외 타입
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ScheduleService {
  static const _baseUrl = 'http://127.0.0.1:5000/api/schedules';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _client;

  /// 테스트용으로 주입 가능하도록 http.Client를 받습니다. 기본은 http.Client().
  ScheduleService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> get _token async => await _storage.read(key: 'jwt_token');

  /// 공통 헤더 생성
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
      final js = jsonDecode(resp.body) as List<dynamic>;
      return js.map((e) => Schedule.fromJson(e)).toList();
    } else {
      throw ApiException(resp.statusCode, '스케줄 조회 실패: ${resp.body}');
    }
  }

  /// 새 스케줄 생성
  Future<Schedule> createSchedule(Schedule s) async {
    final resp = await _client.post(
      Uri.parse(_baseUrl),
      headers: await _headers(),
      body: jsonEncode(s.toJson()),
    );
    if (resp.statusCode == 201) {
      return Schedule.fromJson(jsonDecode(resp.body));
    } else {
      throw ApiException(resp.statusCode, '스케줄 생성 실패: ${resp.body}');
    }
  }

  /// 기존 스케줄 수정
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> changes) async {
    final resp = await _client.put(
      Uri.parse('$_baseUrl/$id'),
      headers: await _headers(),
      body: jsonEncode(changes),
    );
    if (resp.statusCode == 200) {
      return Schedule.fromJson(jsonDecode(resp.body));
    } else {
      throw ApiException(resp.statusCode, '스케줄 수정 실패: ${resp.body}');
    }
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(int id) async {
    final resp = await _client.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: await _headers(),
    );
    if (resp.statusCode != 200) {
      throw ApiException(resp.statusCode, '스케줄 삭제 실패: ${resp.body}');
    }
  }
}