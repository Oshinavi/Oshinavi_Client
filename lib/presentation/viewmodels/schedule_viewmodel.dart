import 'package:flutter/foundation.dart';
import '../../domain/usecases/manage_schedule_usecase.dart';
import '../../domain/entities/schedule.dart';

/// ScheduleViewModel: MVVM 패턴에 따라 UseCase 호출 및 상태 관리 수행
/// - 일정 조회, 추가, 수정, 삭제
/// - 예외 발생 시 rethrow 하여 View(UI) 레이어에서 처리
class ScheduleViewModel extends ChangeNotifier {
  final ManageScheduleUseCase _useCase;

  bool isLoading = false;
  String? errorMessage;
  List<Schedule> schedules = [];

  ScheduleViewModel({required ManageScheduleUseCase useCase})
      : _useCase = useCase;

  /// 내 스케줄 목록 조회
  Future<void> loadSchedules() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      schedules = await _useCase.fetchSchedules();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 일정 추가
  /// - 예외 발생 시 rethrow 하여 UI에서 다이얼로그로 처리
  Future<void> addSchedule(Schedule schedule) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newSchedule = await _useCase.createSchedule(schedule);
      schedules.add(newSchedule);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 일정 수정
  /// - 예외 발생 시 rethrow
  Future<void> updateSchedule(int id, Map<String, dynamic> changes) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await _useCase.updateSchedule(id, changes);
      final idx = schedules.indexWhere((s) => s.id == id);
      if (idx != -1) schedules[idx] = updated;
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 일정 삭제
  /// - 예외 발생 시 rethrow
  Future<void> deleteSchedule(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _useCase.deleteSchedule(id);
      schedules.removeWhere((s) => s.id == id);
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}