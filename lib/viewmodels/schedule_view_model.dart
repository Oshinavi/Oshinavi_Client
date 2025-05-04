import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleService _api;

  /// 내부 리스트는 직접 수정하지 않고, 외부엔 읽기 전용으로 노출합니다.
  final List<Schedule> _schedules = [];

  bool _isLoading = false;
  String? _error;

  ScheduleViewModel({required ScheduleService api}) : _api = api;

  /// MVVM 패턴에 맞게 외부에 노출하는 불변 리스트
  UnmodifiableListView<Schedule> get schedules =>
      UnmodifiableListView(_schedules);

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 반복되는 로딩/에러 처리 패턴을 추출한 헬퍼
  Future<void> _runSafe(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 스케줄 목록 불러오기
  Future<void> loadSchedules() async {
    await _runSafe(() async {
      final list = await _api.fetchMySchedules();
      _schedules
        ..clear()
        ..addAll(list);
    });
    if (_error != null) throw Exception(_error);
  }

  /// 새 스케줄 추가
  Future<void> addSchedule(Schedule s) async {
    await _runSafe(() async {
      final created = await _api.createSchedule(s);
      _schedules.add(created);
    });
    if (_error != null) throw Exception(_error);
  }

  /// 스케줄 수정
  Future<void> updateSchedule(int id, Map<String, dynamic> changes) async {
    await _runSafe(() async {
      final updated = await _api.updateSchedule(id, changes);
      final idx = _schedules.indexWhere((e) => e.id == id);
      if (idx != -1) _schedules[idx] = updated;
    });
    if (_error != null) throw Exception(_error);
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(int id) async {
    await _runSafe(() async {
      await _api.deleteSchedule(id);
      _schedules.removeWhere((e) => e.id == id);
    });
    if (_error != null) throw Exception(_error);
  }
}