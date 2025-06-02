import 'package:custom_calendar/custom_calendar.dart';
import 'package:intl/intl.dart';

/// 캘린더 위젯 내 이벤트가 차지할 row 번호를 계산 및 할당하는 매니저
/// - 같은 주(일요일 기준)에 여러 이벤트가 겹치지 않도록 row 번호를 조정
class EventRowManager {
  /// 특정 주(yyyy-MM-dd) 기준으로 사용 중인 row 목록
  final Map<String, List<int>> _weekRows = {};

  /// 개별 이벤트 → 할당된 row 번호 매핑
  final Map<Event, int> _eventRow = {};

  /// 내부 상태 초기화
  void reset() {
    _weekRows.clear();
    _eventRow.clear();
  }

  /// 주어진 이벤트에 대해 차지할 줄 번호를 계산하고 반환
  /// - startTime/ endTime을 기준으로 주 단위로 row 충돌 검사
  int assignRow(Event event) {
    // 시작/종료 시간 가져오기 (효율적 시작/종료 시간 우선)
    final DateTime? start = event.effectiveStartTime ?? event.startTime;
    final DateTime? end = event.effectiveEndTime ?? event.endTime;
    if (start == null || end == null) return 0;

    // 시작 이벤트가 속한 주(일요일 기준) 날짜 계산
    DateTime currentWeek = _weekStart(start);
    int maxRow = 0;

    // 이벤트가 걸치는 모든 주를 순회하며 사용 가능한 row 찾기
    while (!currentWeek.isAfter(end)) {
      final key = _weekKey(currentWeek);
      final List<int> usedRows = _weekRows[key] ?? [];

      // 사용된 row와 충돌하지 않도록 0부터 비어있는 row 탐색
      int row = 0;
      while (usedRows.contains(row)) {
        row++;
      }

      if (row > maxRow) maxRow = row;
      _weekRows[key] = [...usedRows, row];

      // 다음 주로 넘어가기
      currentWeek = currentWeek.add(const Duration(days: 7));
    }

    _eventRow[event] = maxRow;
    return maxRow;
  }

  /// 이미 할당된 이벤트의 row 번호 반환 (없으면 null)
  int? getRow(Event event) => _eventRow[event];

  /// 주(week)의 키 문자열 생성 (YYYY-MM-DD 포맷)
  String _weekKey(DateTime date) => DateFormat('yyyy-MM-dd').format(_weekStart(date));

  /// 주(week) 시작일 (일요일 기준) 계산
  DateTime _weekStart(DateTime date) {
    // weekday: 월=1 ... 일=7 → 일요일이면 weekday%7 == 0
    return date.subtract(Duration(days: date.weekday % 7));
  }
}