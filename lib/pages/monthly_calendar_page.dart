import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_calendar/custom_calendar.dart';
import 'package:custom_calendar/src/utils/extension.dart'; // withoutTime 확장
import 'package:intl/intl.dart';

import '../models/schedule.dart';
import '../viewmodels/schedule_view_model.dart';
import '../services/schedule_service.dart';

class MonthlyCalendarPage extends StatefulWidget {
  const MonthlyCalendarPage({Key? key}) : super(key: key);

  @override
  State<MonthlyCalendarPage> createState() => _MonthlyCalendarPageState();
}

class _MonthlyCalendarPageState extends State<MonthlyCalendarPage> {
  final EventsController _controller = EventsController();
  final _calendarKey = GlobalKey<CustomEventsMonthsState>();
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleViewModel>().loadSchedules();
    });
  }

  Color _randomColor() =>
      Colors.primaries[Random().nextInt(Colors.primaries.length)].shade400;

  void _goPrev() {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1);
    _calendarKey.currentState?.jumpToDateCustom(prev);
    setState(() => _currentMonth = prev);
  }

  void _goNext() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    _calendarKey.currentState?.jumpToDateCustom(next);
    setState(() => _currentMonth = next);
  }

  Future<void> _onAdd() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final twtCtrl = TextEditingController();
    DateTime? startAt;
    DateTime? endAt;

    const categories = [
      '일반', '방송', '라디오', '라이브',
      '음반', '굿즈', '영상', '게임',
    ];
    String selectedCategory = categories.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          Widget _buildDateTimeField(
              String label, DateTime? v, VoidCallback onTap) {
            final text = v == null
                ? ''
                : DateFormat('yyyy.MM.dd HH:mm').format(v);
            return TextField(
              readOnly: true,
              decoration: InputDecoration(labelText: label, hintText: '선택'),
              controller: TextEditingController(text: text),
              onTap: onTap,
            );
          }

          return AlertDialog(
            title: const Text('새 이벤트 추가'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: '카테고리'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: twtCtrl,
                  decoration: const InputDecoration(
                      labelText: '관련 트위터 스크린네임'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: '설명'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildDateTimeField('시작 일시', startAt, () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (d == null) return;
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t == null) return;
                  setState(() {
                    startAt = DateTime(
                        d.year, d.month, d.day, t.hour, t.minute);
                    endAt ??= startAt!.add(const Duration(hours: 1));
                  });
                }),
                const SizedBox(height: 8),
                _buildDateTimeField('종료 일시', endAt, () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: startAt ?? DateTime.now(),
                    firstDate: startAt ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (d == null) return;
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: startAt != null
                        ? TimeOfDay(
                        hour: (startAt!.hour + 1) % 24,
                        minute: startAt!.minute)
                        : TimeOfDay.now(),
                  );
                  if (t == null) return;
                  setState(() {
                    endAt = DateTime(
                        d.year, d.month, d.day, t.hour, t.minute);
                  });
                }),
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('취소')),
              TextButton(
                  onPressed: () {
                    if (titleCtrl.text.isEmpty ||
                        startAt == null ||
                        endAt == null) return;
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('추가')),
            ],
          );
        });
      },
    );
    if (ok != true) return;

    final newSched = Schedule(
      id: 0,
      title: titleCtrl.text,
      category: selectedCategory,
      startAt: startAt!,
      endAt: endAt!,
      description: descCtrl.text,
      relatedTwitterInternalId: twtCtrl.text,
      createdByUserId: 0,
    );

    try {
      await context.read<ScheduleViewModel>().addSchedule(newSched);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정이 추가되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추가 실패: ${e.toString()}')),
      );
    }
  }

  Future<void> _confirmDelete(int id) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('삭제',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (yes != true) return;

    try {
      await context.read<ScheduleViewModel>().deleteSchedule(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정이 삭제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${e.toString()}')),
      );
    }
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
            Text('관련 트위터: ${s.relatedTwitterInternalId}'),
            Text('시작: ${DateFormat('yyyy.MM.dd HH:mm').format(s.startAt)}'),
            Text('종료: ${DateFormat('yyyy.MM.dd HH:mm').format(s.endAt)}'),
            const SizedBox(height: 8),
            Text(s.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: 수정 기능 구현 예정
            },
            child: const Text('수정'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmDelete(s.id);
            },
            child:
            const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('닫기')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthLabel =
    DateFormat('yyyy년 M월').format(_currentMonth);

    return Scaffold(
      appBar: AppBar(
        // 다크모드 시 짙은 배경, 라이트 모드 시 흰색
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black),
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _goPrev),
          Text(monthLabel,
              style: TextStyle(
                  color:
                  isDark ? Colors.white : Colors.black)),
          IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _goNext),
        ]),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),

      body: Consumer<ScheduleViewModel>(
        builder: (ctx, vm, _) {
          if (vm.isLoading) {
            return const Center(
                child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            // 달력은 계속 렌더, SnackBar 한 번만 띄움
            WidgetsBinding.instance
                .addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('에러 발생: ${vm.error}')),
              );
            });
          }

          // 이벤트 컨트롤러 갱신
          final events = vm.schedules.map((s) {
            return Event(
              startTime: s.startAt,
              endTime: s.endAt,
              title: s.title,
              description: s.description,
              color: _randomColor(),
              data: s,
            );
          }).toList();
          _controller.updateCalendarData((cal) {
            cal.clearAll();
            cal.addEvents(events);
          });

          return CustomEventsMonths(
            key: _calendarKey,
            controller: _controller,
            weekParam: WeekParam(
              startOfWeekDay: 7,
              headerDayBuilder: (dow) {
                const labels = {
                  1: 'M',
                  2: 'T',
                  3: 'W',
                  4: 'T',
                  5: 'F',
                  6: 'S',
                  7: 'S',
                };
                Color color;
                if (dow == 7) {
                  color = Colors.redAccent; // Sunday
                } else if (dow == 6) {
                  color = Colors.blueAccent; // Saturday
                } else {
                  color = isDark ? Colors.white : Colors.black;
                }
                return Center(
                  child: Text(
                    labels[dow]!,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            automaticAdjustScrollToStartOfMonth: true,
            onMonthChange: (m) =>
                setState(() => _currentMonth = m),
            daysParam: DaysParam(
              dayEventBuilder: (event, w, h) {
                final idx = event.daysIndex ?? 0;
                final totalDays = ((event.effectiveEndTime ??
                    event.endTime)!
                    .difference(event.effectiveStartTime ??
                    event.startTime)
                    .inDays) +
                    1;
                final segStartDate = (event.effectiveStartTime ??
                    event.startTime)
                    .withoutTime
                    .add(Duration(days: idx));
                final wd0 = segStartDate.weekday % 7;
                final remain = 7 - wd0;
                final spanThisWeek =
                min(totalDays - idx, remain);
                if (spanThisWeek <= 0)
                  return const SizedBox.shrink();

                final width = (w ?? 0) * spanThisWeek;
                final height = h ?? 0;

                return GestureDetector(
                  onTap: () => _onEventTap(event),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: DraggableMonthEvent(
                      onDragEnd: (d) =>
                          _controller.calendarData
                              .moveEvent(event, d),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 4),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: event.color,
                          borderRadius:
                          BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.title ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: event.textColor,
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}