import '../entities/schedule.dart';
import '../repositories/schedule_repository.dart';

/// 스케줄 관리 관련 UseCase 클래스
class ManageScheduleUseCase {
  final ScheduleRepository _repository;

  ManageScheduleUseCase(this._repository);

  /// 내 스케줄 목록 조회
  Future<List<Schedule>> fetchSchedules() async {
    return await _repository.fetchMySchedules();
  }

  /// 새 스케줄 생성
  Future<Schedule> createSchedule(Schedule schedule) async {
    return await _repository.createSchedule(schedule);
  }

  /// 스케줄 수정
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> changes) async {
    return await _repository.updateSchedule(id, changes);
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(int id) async {
    return await _repository.deleteSchedule(id);
  }
}