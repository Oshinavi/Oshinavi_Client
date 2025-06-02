import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediaproject/data/datasources/schedule_api.dart';
import 'package:mediaproject/data/models/schedule_model.dart';
import 'package:mediaproject/domain/entities/schedule.dart';
import 'package:mediaproject/domain/repositories/schedule_repository.dart';

/// 프론트 전용 커스텀 예외 클래스
class ScheduleBadRequestException implements Exception {
  final String message;
  ScheduleBadRequestException([this.message = '잘못된 요청입니다.']);
  @override
  String toString() => 'ScheduleBadRequestException: $message';
}

class ScheduleNotFoundException implements Exception {
  final String message;
  ScheduleNotFoundException([this.message = '존재하지 않는 항목입니다.']);
  @override
  String toString() => 'ScheduleNotFoundException: $message';
}

class ScheduleConflictException implements Exception {
  final String message;
  ScheduleConflictException([this.message = '충돌이 발생했습니다.']);
  @override
  String toString() => 'ScheduleConflictException: $message';
}

class ScheduleServerException implements Exception {
  final String message;
  ScheduleServerException([this.message = '서버 오류가 발생했습니다.']);
  @override
  String toString() => 'ScheduleServerException: $message';
}

/// ScheduleRepository 인터페이스 구현체
/// - ScheduleApi를 통해 REST 호출을 수행하고
///   HTTP 상태 코드에 따라 프론트 전용 예외로 래핑하여 던짐
class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleApi _api = ScheduleApi();

  @override
  Future<List<Schedule>> fetchMySchedules() async {
    try {
      final models = await _api.fetchMySchedules();
      return models.map((m) => m.toEntity()).toList();
    } on http.Response catch (res) {
      final code = res.statusCode;
      var detail = '알 수 없는 오류가 발생했습니다.';
      try {
        final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
        detail = jsonMap['detail'] as String? ?? detail;
      } catch (_) {}

      if (code == 401) {
        throw ScheduleBadRequestException('인증되지 않았습니다. 다시 로그인해 주세요.');
      } else {
        throw ScheduleServerException(detail);
      }
    } catch (_) {
      throw ScheduleServerException('서버와 통신하는 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<Schedule> createSchedule(Schedule schedule) async {
    final requestModel = ScheduleModel.fromEntity(schedule);

    try {
      final createdModel = await _api.createSchedule(requestModel);
      return createdModel.toEntity();
    } on http.Response catch (res) {
      final code = res.statusCode;
      var detail = '알 수 없는 오류가 발생했습니다.';
      try {
        final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
        detail = jsonMap['detail'] as String? ?? detail;
      } catch (_) {}

      if (code == 400) {
        throw ScheduleBadRequestException(detail);
      } else if (code == 404) {
        throw ScheduleNotFoundException(detail);
      } else if (code == 409) {
        throw ScheduleConflictException(detail);
      } else if (code >= 500) {
        throw ScheduleServerException(detail);
      } else {
        throw ScheduleServerException('서버와 통신 중 알 수 없는 오류가 발생했습니다.');
      }
    } catch (_) {
      throw ScheduleServerException('서버와 통신하는 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> changes) async {
    try {
      final updatedModel = await _api.updateSchedule(id, changes);
      return updatedModel.toEntity();
    } on http.Response catch (res) {
      final code = res.statusCode;
      var detail = '알 수 없는 오류가 발생했습니다.';
      try {
        final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
        detail = jsonMap['detail'] as String? ?? detail;
      } catch (_) {}

      if (code == 400) {
        throw ScheduleBadRequestException(detail);
      } else if (code == 404) {
        throw ScheduleNotFoundException(detail);
      } else if (code == 409) {
        throw ScheduleConflictException(detail);
      } else if (code >= 500) {
        throw ScheduleServerException(detail);
      } else {
        throw ScheduleServerException('서버와 통신하는 중 알 수 없는 오류가 발생했습니다.');
      }
    } catch (_) {
      throw ScheduleServerException('서버와 통신하는 중 오류가 발생했습니다.');
    }
  }

  @override
  Future<void> deleteSchedule(int id) async {
    try {
      await _api.deleteSchedule(id);
    } on http.Response catch (res) {
      final code = res.statusCode;
      var detail = '알 수 없는 오류가 발생했습니다.';
      try {
        final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
        detail = jsonMap['detail'] as String? ?? detail;
      } catch (_) {}

      if (code == 400) {
        throw ScheduleBadRequestException(detail);
      } else if (code == 404) {
        throw ScheduleNotFoundException(detail);
      } else if (code == 409) {
        throw ScheduleConflictException(detail);
      } else if (code >= 500) {
        throw ScheduleServerException(detail);
      } else {
        throw ScheduleServerException('서버와 통신 중 알 수 없는 오류가 발생했습니다.');
      }
    } catch (_) {
      throw ScheduleServerException('서버와 통신하는 중 오류가 발생했습니다.');
    }
  }
}