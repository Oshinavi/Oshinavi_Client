// lib/pages/monthly_calendar_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_calendar/custom_calendar.dart';
import 'package:custom_calendar/src/utils/extension.dart';
import 'package:mediaproject/pages/event_detail_page.dart';
import 'package:intl/intl.dart';

import '../models/schedule.dart';
import '../viewmodels/schedule_view_model.dart';
import '../utils/color_generator.dart';

class MonthlyCalendarPage extends StatefulWidget {
  const MonthlyCalendarPage({Key? key}) : super(key: key);

  @override
  State<MonthlyCalendarPage> createState() => _MonthlyCalendarPageState();
}

class _MonthlyCalendarPageState extends State<MonthlyCalendarPage> {
  final EventsController _controller = EventsController();
  final _calendarKey = GlobalKey<CustomEventsMonthsState>();
  final ColorGenerator _colorGenerator = ColorGenerator();
  DateTime _currentMonth = DateTime.now();
  bool _colorReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _colorGenerator.init();
      setState(() => _colorReady = true);
      context.read<ScheduleViewModel>().loadSchedules();
    });
  }

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

  Widget _buildDateTimeField(String label, DateTime? value, VoidCallback onTap) {
    final text = value == null ? '' : DateFormat('yyyy.MM.dd HH:mm').format(value);
    return TextField(
      readOnly: true,
      decoration: InputDecoration(labelText: label, hintText: '선택'),
      controller: TextEditingController(text: text),
      onTap: onTap,
    );
  }
  Future<void> _onAdd() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final twtCtrl = TextEditingController();
    DateTime? startAt;
    DateTime? endAt;

    const categories = [
      '일반', '방송', '라디오', '라이브', '음반', '굿즈', '영상', '게임',
    ];
    String selectedCategory = categories.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('새 이벤트 추가'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: '제목')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: '카테고리'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
                const SizedBox(height: 8),
                TextField(controller: twtCtrl, decoration: const InputDecoration(labelText: '관련 오시 id(@id)')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: '설명'), maxLines: 2),
                const SizedBox(height: 12),
                _buildDateTimeField('시작 일시', startAt, () async {
                  final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d == null) return;
                  final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                  if (t == null) return;
                  setState(() {
                    startAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                    endAt ??= startAt!.add(const Duration(hours: 1));
                  });
                }),
                const SizedBox(height: 8),
                _buildDateTimeField('종료 일시', endAt, () async {
                  final d = await showDatePicker(context: ctx, initialDate: startAt ?? DateTime.now(), firstDate: startAt ?? DateTime.now(), lastDate: DateTime(2100));
                  if (d == null) return;
                  final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                  if (t == null) return;
                  setState(() {
                    endAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                  });
                }),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
              TextButton(onPressed: () => Navigator.pop(ctx, titleCtrl.text.isEmpty || startAt == null || endAt == null ? false : true), child: const Text('추가')),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('일정이 추가되었습니다.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('추가 실패: $e')));
    }
  }

  Future<void> _onEventTap(Event e) async {
    final s = e.data as Schedule;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EventDetailPage(schedule: s)),
    );
    if (changed == true) {
      await context.read<ScheduleViewModel>().loadSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthLabel = DateFormat('yyyy년 M월').format(_currentMonth);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: _goPrev),
          Text(monthLabel, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: _goNext),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
      body: !_colorReady
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ScheduleViewModel>(
        builder: (ctx, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = vm.schedules.map((s) {
            final key = '${s.relatedTwitterInternalId}_${s.id}';
            final color = _colorGenerator.getColor(key);
            return Event(
              startTime: s.startAt,
              endTime: s.endAt,
              title: s.title,
              description: s.description,
              color: color,
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
            automaticAdjustScrollToStartOfMonth: true,
            onMonthChange: (m) => setState(() => _currentMonth = m),
            weekParam: WeekParam(
              startOfWeekDay: 7,
              headerDayBuilder: (dow) {
                const labels = {1:'M',2:'T',3:'W',4:'T',5:'F',6:'S',7:'S'};
                Color color = dow==7
                    ? Colors.redAccent
                    : dow==6
                    ? Colors.blueAccent
                    : (isDark ? Colors.white : Colors.black);
                return Center(child: Text(labels[dow]!, style: TextStyle(color: color, fontWeight: FontWeight.bold)));
              },
            ),
            daysParam: DaysParam(
              dayHeaderBuilder: (date) {
                final isInCurrentMonth = date.month == _currentMonth.month;
                final isToday = DateUtils.isSameDay(date, DateTime.now());
                return DefaultMonthDayHeader(
                  text: date.day.toString(),
                  isToday: isToday,
                  textColor: isInCurrentMonth ? null : Theme.of(context).disabledColor,
                  todayTextColor: Theme.of(context).colorScheme.onPrimary,
                  todayBackgroundColor: Theme.of(context).colorScheme.primary,
                );
              },
              dayEventBuilder: (event, w, h) {
                final s = event.data as Schedule;
                final idx = event.daysIndex ?? 0;
                final totalDays = ((event.effectiveEndTime ?? event.endTime)!
                    .difference(event.effectiveStartTime ?? event.startTime)
                    .inDays) +
                    1;
                final segStartDate = (event.effectiveStartTime ?? event.startTime)
                    .withoutTime
                    .add(Duration(days: idx));
                final wd0 = segStartDate.weekday % 7;
                final remain = 7 - wd0;
                final spanThisWeek = min(totalDays - idx, remain);
                if (spanThisWeek <= 0) return const SizedBox.shrink();
                final width = (w ?? 0) * spanThisWeek;
                final height = h ?? 0;

                return GestureDetector(
                  onTap: () async {
                    // ① 상세 페이지로 이동
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EventDetailPage(schedule: s),
                      ),
                    );
                    // ② true 이면 다시 불러오기
                    if (changed == true) {
                      await context.read<ScheduleViewModel>().loadSchedules();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: DraggableMonthEvent(
                      onDragEnd: (d) => _controller.calendarData.moveEvent(event, d),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: event.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.title ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: event.textColor.computeLuminance() < 0.4
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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