import 'package:custom_calendar/custom_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class MonthlyCalendarPage extends StatefulWidget {
  const MonthlyCalendarPage({super.key});

  @override
  State<MonthlyCalendarPage> createState() => _MonthlyCalendarPageState();
}

class _MonthlyCalendarPageState extends State<MonthlyCalendarPage> {
  final EventsController _controller = EventsController();
  final GlobalKey<CustomEventsMonthsState> _calendarKey = GlobalKey();
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadInitialEvents();
  }
  Color getRandomEventColor() {
    final random = Random();
    return Colors.primaries[random.nextInt(Colors.primaries.length)].shade400;
  }

  void _loadInitialEvents() {
    final events = [
      Event(
        startTime: DateTime(2025, 4, 26, 16, 30),
        endTime: DateTime(2025, 4, 26, 19, 30),
        title: '하스노소라 4th 이시카와 공연',
        description: '하스노소라 4th 이시카와 공연 day1',
        color: getRandomEventColor(),
      ),
      Event(
        startTime: DateTime(2025, 4, 27, 15, 30),
        endTime: DateTime(2025, 4, 27, 18, 30),
        title: '하스노소라 4th 이시카와 공연',
        description: '하스노소라 4th 이시카와 공연 day2',
        color: getRandomEventColor(),
      ),
      Event(
        startTime: DateTime(2025, 4, 17, 20, 30),
        endTime: DateTime(2025, 4, 17, 21, 30),
        title: 'WithxMeets',
        description: '위드미츠 루리노&이즈미',
        color: Color(0xFF1ebecd)
      ),
      Event(
        startTime: DateTime(2025, 4, 19, 14, 00),
        endTime: DateTime(2025, 4, 19, 15, 00),
        title: 'WithxMeets',
        description: '위드미츠 코스즈',
          color: Color(0xFFFAD764),
      ),
      Event(
        startTime: DateTime(2025, 4, 21, 20, 30),
        endTime: DateTime(2025, 4, 21, 21, 30),
        title: 'WithxMeets',
        description: '위드미츠 히메',
          color: Color(0xFF9d8de2)
      ),
    ];

    _controller.updateCalendarData((calendarData) {
      calendarData.addEvents(events);
    });
  }

  void _goToPreviousMonth() {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    _calendarKey.currentState?.jumpToDateCustom(newMonth);
    setState(() {
      _currentMonth = newMonth;
    });
  }

  void _goToNextMonth() {
    final newMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    _calendarKey.currentState?.jumpToDateCustom(newMonth);
    setState(() {
      _currentMonth = newMonth;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthText = DateFormat('yyyy년 M월').format(_currentMonth);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _goToPreviousMonth,
            ),
            Text(
              monthText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _goToNextMonth,
            ),
          ],
        ),
      ),
      body: CustomEventsMonths(
        key: _calendarKey,
        controller: _controller,
        automaticAdjustScrollToStartOfMonth: true,
        onMonthChange: (newMonth) {
          setState(() {
            _currentMonth = newMonth;
          });
        },
        daysParam: DaysParam(
          dayEventBuilder: (event, width, height) {
            return DraggableMonthEvent(
              child: getCustomEvent(context, width, height, event),
              onDragEnd: (day) {
                _controller.updateCalendarData((data) => move(data, event, day));
              },
            );
          },
        ),
      ),
    );
  }

  Widget getCustomEvent(
      BuildContext context,
      double? width,
      double? height,
      Event event,
      ) {
    return SizedBox(
      width: width,
      height: height,
      child: DefaultMonthDayEvent(
        event: event,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("클릭: ${event.title}")),
          );
        },
      ),
    );
  }

  void move(CalendarData data, Event event, DateTime newDay) {
    data.moveEvent(
      event,
      newDay.copyWith(
        hour: event.effectiveStartTime?.hour ?? 0,
        minute: event.effectiveStartTime?.minute ?? 0,
      ),
    );
  }
}