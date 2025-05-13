import 'package:custom_calendar/custom_calendar.dart';
import 'package:intl/intl.dart';

class EventRowManager {
  final Map<String, List<int>> _weekRows = {};
  final Map<Event, int> _eventRow = {};

  void reset() {
    _weekRows.clear();
    _eventRow.clear();
  }

  /// 이벤트가 차지할 줄 번호를 할당하고 반환
  int assignRow(Event event) {
    final DateTime? start = event.effectiveStartTime ?? event.startTime;
    final DateTime? end = event.effectiveEndTime ?? event.endTime;
    if (start == null || end == null) return 0; // ✅ null 방어 처리

    DateTime currentWeek = _weekStart(start);
    int maxRow = 0;

    // 주별로 줄 번호를 할당
    while (!currentWeek.isAfter(end)) {
      final key = _key(currentWeek);
      final rows = _weekRows[key] ?? [];

      int row = 0;
      while (rows.contains(row)) {
        row++;
      }

      if (row > maxRow) maxRow = row;

      _weekRows[key] = [...rows, row];
      currentWeek = currentWeek.add(const Duration(days: 7));
    }

    _eventRow[event] = maxRow;
    return maxRow;
  }

  int? getRow(Event event) => _eventRow[event];

  String _key(DateTime date) => DateFormat('yyyy-MM-dd').format(_weekStart(date));

  /// 해당 날짜의 주 시작(일요일 기준) 날짜 반환
  DateTime _weekStart(DateTime date) => date.subtract(Duration(days: date.weekday % 7));
}