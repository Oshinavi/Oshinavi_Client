import '../entities/schedule.dart';

/// 스케줄(Schedule) 관련 동작을 정의하는 추상 인터페이스
abstract class ScheduleRepository {
  /// 내 스케줄 목록 조회
  Future<List<Schedule>> fetchMySchedules();

  /// 새 스케줄 생성
  Future<Schedule> createSchedule(Schedule schedule);

  /// 기존 스케줄 수정
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> changes);

  /// 스케줄 삭제
  Future<void> deleteSchedule(int id);
}