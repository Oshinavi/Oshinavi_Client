import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  final List<NeatCleanCalendarEvent> _eventList = [
    // NeatCleanCalendarEvent(
    //   '회의 A',
    //   startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 0),
    //   endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 0),
    //   description: '팀 회의',
    //   color: Colors.blue,
    // ),
    // NeatCleanCalendarEvent(
    //   '점심 미팅',
    //   startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 30),
    //   endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13, 30),
    //   description: '클라이언트와 미팅',
    //   color: Colors.orange,
    // ),
  ];

  List<NeatCleanCalendarEvent> get _filteredEvents {
    return _eventList.where((e) =>
    e.startTime.year == _selectedDate.year &&
        e.startTime.month == _selectedDate.month &&
        e.startTime.day == _selectedDate.day
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = List<NeatCleanCalendarEvent>.from(_filteredEvents)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(title: const Text("캘린더 보기")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxCalendarHeight = constraints.maxHeight * 0.52;

          return Column(
            children: [

              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxCalendarHeight),
                child: Calendar(
                  startOnMonday: true,
                  weekDays: const ['월', '화', '수', '목', '금', '토', '일'],
                  eventsList: _eventList,
                  showEvents: false,
                  isExpandable: false,
                  isExpanded: true,
                  hideArrows: false,
                  locale: 'ko_KR',
                  todayButtonText: '오늘',
                  allDayEventText: '하루 종일',
                  multiDayEndText: '끝',
                  expandableDateFormat: 'yyyy년 MM월 dd일 EEEE',
                  selectedColor: Colors.pink,
                  selectedTodayColor: Colors.red,
                  todayColor: Colors.blue,
                  eventDoneColor: Colors.green,
                  dayOfWeekStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),

              /// 나머지 영역에 이벤트 리스트 표시 (더 위로 올라가도록)
              Expanded(
                child: sortedEvents.isEmpty
                    ? const Center(child: Text("이 날은 일정이 없어요 😊"))
                    : ListView.builder(
                  itemCount: sortedEvents.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  itemBuilder: (context, index) {
                    final event = sortedEvents[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.circle, color: event.color, size: 12),
                        title: Text(
                          event.summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} "
                              "~ ${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          // 일정 상세 보기 Dialog
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(event.summary),
                              content: Text(event.description ?? "설명이 없습니다."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("닫기"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 일정 추가 기능
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}