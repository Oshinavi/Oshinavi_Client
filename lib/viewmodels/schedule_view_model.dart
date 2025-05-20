import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleService _api;

  final List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  ScheduleViewModel({required ScheduleService api}) : _api = api;

  UnmodifiableListView<Schedule> get schedules =>
      UnmodifiableListView(_schedules);
  bool get isLoading => _isLoading;
  String? get error => _error;

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
  }

  /// 새 스케줄 추가
  Future<void> addSchedule(Schedule s) async {
    await _runSafe(() async {
      final created = await _api.createSchedule(s);
      _schedules.add(created);
    });
  }

  /// 스케줄 수정 (권한 에러는 뷰로 전달)
  Future<void> updateSchedule(int id, Map<String, dynamic> changes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _api.updateSchedule(id, changes);
      final idx = _schedules.indexWhere((e) => e.id == id);
      if (idx != -1) _schedules[idx] = updated;
    } on ApiException catch (e) {
      // 400 권한 에러는 뷰단으로 다시 던집니다.
      rethrow;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 스케줄 삭제 (권한 에러는 뷰로 전달)
  Future<void> deleteSchedule(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.deleteSchedule(id);
      _schedules.removeWhere((e) => e.id == id);
    } on ApiException catch (e) {
      // 400 권한 에러는 뷰단으로 다시 던집니다.
      rethrow;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}