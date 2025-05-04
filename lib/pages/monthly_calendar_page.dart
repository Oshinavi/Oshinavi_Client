import 'package:flutter/material.dart';
import 'package:custom_calendar/custom_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import '../viewmodels/schedule_view_model.dart';
import '../services/schedule_service.dart';
import '../models/schedule.dart';

class MonthlyCalendarPage extends StatefulWidget {
  const MonthlyCalendarPage({Key? key}) : super(key: key);

  @override
  State<MonthlyCalendarPage> createState() => _MonthlyCalendarPageState();
}

class _MonthlyCalendarPageState extends State<MonthlyCalendarPage> {
  late final ScheduleViewModel _vm;
  final EventsController _controller = EventsController();
  final GlobalKey<CustomEventsMonthsState> _calendarKey = GlobalKey();
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _vm = ScheduleViewModel(api: ScheduleService());
    _vm.addListener(_onSchedulesChanged);
    _vm.loadSchedules();
  }

  @override
  void dispose() {
    _vm.removeListener(_onSchedulesChanged);
    super.dispose();
  }

  void _onSchedulesChanged() {
    final evs = _vm.schedules.map((s) => Event(
      uniqueId: s.id.toString(), // ✅ 고유 ID 명시
      startTime: s.startAt,
      endTime: s.endAt,
      title: s.title,
      description: s.description,
      color: Theme.of(context).colorScheme.primary,
      data: s,
    )).toList();

    _controller.updateCalendarData((cal) {
      cal.clearAll();
      cal.addEvents(evs);
    });
  }

  void _goPrev() {
    final nm = DateTime(_currentMonth.year, _currentMonth.month - 1);
    _calendarKey.currentState?.jumpToDateCustom(nm);
    setState(() => _currentMonth = nm);
  }

  void _goNext() {
    final nm = DateTime(_currentMonth.year, _currentMonth.month + 1);
    _calendarKey.currentState?.jumpToDateCustom(nm);
    setState(() => _currentMonth = nm);
  }

  Future<void> _onAdd() async {
    // TODO: 일정 추가 다이얼로그 구현
  }

  Future<void> _onEventTap(Event e) async {
    final s = e.data as Schedule?;
    if (s == null) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('카테고리: ${s.category}'),
            Text('시작: ${DateFormat('yyyy.MM.dd HH:mm').format(s.startAt)}'),
            Text('종료: ${DateFormat('yyyy.MM.dd HH:mm').format(s.endAt)}'),
            const SizedBox(height: 8),
            Text(s.description),
          ],
        ),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(ctx).pop();
            _showEditDialog(s);
          }, child: const Text('수정')),
          TextButton(onPressed: () {
            Navigator.of(ctx).pop();
            _confirmDelete(s.id);
          }, child: const Text('삭제', style: TextStyle(color: Colors.red))),
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('닫기')),
        ],
      ),
    );
  }

  void _showEditDialog(Schedule s) {
    // TODO: 수정 폼 띄우고, _vm.updateSchedule 호출
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('취소')),
          TextButton(onPressed: () async {
            Navigator.of(ctx).pop();
            await _vm.deleteSchedule(id);
          }, child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext c) {
    final monthText = DateFormat('yyyy년 M월').format(_currentMonth);
    final isDark    = Theme.of(c).brightness == Brightness.dark;
    const wd        = ['월','화','수','목','금','토','일'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: _goPrev),
          Text(monthText, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: _goNext),
        ]),
      ),
      body: CustomEventsMonths(
        key: _calendarKey,
        controller: _controller,
        weekParam: WeekParam(
          startOfWeekDay: 1,
          headerHeight: 28,
          headerDayBuilder: (d) {
            final col = (d == 7)
                ? Colors.redAccent
                : (d == 6)
                ? Colors.blueAccent
                : (isDark ? Colors.white : Colors.black);
            return Center(child: Text(wd[d - 1], style: TextStyle(color: col, fontWeight: FontWeight.w700)));
          },
        ),
        automaticAdjustScrollToStartOfMonth: true,
        onMonthChange: (m) => setState(() => _currentMonth = m),
        daysParam: DaysParam(
          dayHeaderBuilder: (date) {
            final inMonth = date.month == _currentMonth.month;
            final wd = date.weekday;
            final col = (wd == 7)
                ? Colors.redAccent
                : (wd == 6)
                ? Colors.blueAccent
                : (inMonth ? Theme.of(c).colorScheme.onSurface : Theme.of(c).disabledColor);
            return DefaultMonthDayHeader(
              text: date.day.toString(),
              isToday: DateUtils.isSameDay(date, DateTime.now()),
              textColor: col,
              todayTextColor: Theme.of(c).colorScheme.onPrimary,
              todayBackgroundColor: Theme.of(c).colorScheme.primary,
            );
          },
          dayEventBuilder: (e, w, h) {
            final idx = e.daysIndex ?? 0;
            if (idx > 0) return const SizedBox.shrink();

            final sDate = e.effectiveStartTime ?? e.startTime;
            final eDate = e.effectiveEndTime ?? e.startTime;
            final startDate = DateTime(sDate.year, sDate.month, sDate.day);
            final endDate   = DateTime(eDate.year, eDate.month, eDate.day);
            final spanDays  = endDate.difference(startDate).inDays + 1;

            final dayWidth  = w ?? 0.0;
            final dayHeight = h ?? 0.0;
            final totalWidth = dayWidth * spanDays;

            return GestureDetector(
              onTap: () => _onEventTap(e),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: totalWidth,
                height: dayHeight,
                child: DraggableMonthEvent(
                  child: DefaultMonthDayEvent(event: e),
                  onDragEnd: (day) => _controller.calendarData.moveEvent(e, day),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}