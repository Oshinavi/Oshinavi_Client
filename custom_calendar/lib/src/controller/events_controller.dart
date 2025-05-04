import 'package:flutter/material.dart';
import '../events/event.dart';
import '../utils/extension.dart';

typedef EventFilter = List<Event>? Function(DateTime date, List<Event>? dayEvents);
typedef UpdateCalendarDataCallback = void Function(CalendarData calendarData);

class EventsController extends ChangeNotifier {
  EventsController();

  final CalendarData calendarData = CalendarData();
  EventFilter dayEventsFilter = (d, ev) => ev;
  DateTime focusedDay = DateTime.now();
  void Function(DateTime)? onFocusedDayChange;

  void updateCalendarData(UpdateCalendarDataCallback fn) {
    fn(calendarData);
    notifyListeners();
  }

  void updateFocusedDay(DateTime day) {
    focusedDay = day;
    onFocusedDayChange?.call(day);
  }

  List<Event>? getFilteredDayEvents(
      DateTime date, {
        bool returnDayEvents = true,
        bool returnFullDayEvent = true,
        bool returnMultiDayEvents = true,
        bool returnMultiFullDayEvents = true,
      }) {
    var list = calendarData.dayEvents[date.withoutTime];
    var filtered = list
        ?.where((e) =>
    e.isFullDay
        ? (e.isMultiDay ? returnMultiFullDayEvents : returnFullDayEvent)
        : (e.isMultiDay ? returnMultiDayEvents : returnDayEvents))
        .toList();
    return dayEventsFilter(date, filtered);
  }

  List<Event>? getSortedFilteredDayEvents(DateTime date) {
    var ev = getFilteredDayEvents(date);
    ev?.sort((a, b) => a.startTime.compareTo(b.startTime));
    return ev;
  }

  @override
  void notifyListeners() => super.notifyListeners();
}

class CalendarData {
  final Map<DateTime, List<Event>> dayEvents = {};

  void addEvents(List<Event> events) {
    for (var event in events) {
      final startDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      final endDt = event.endTime ?? event.startTime;
      final endDate   = DateTime(endDt.year, endDt.month, endDt.day);
      final days      = endDate.difference(startDate).inDays;
      for (var i = 0; i <= days; i++) {
        final day = startDate.add(Duration(days: i));
        final segStart = (i == 0) ? event.startTime : DateTime(day.year, day.month, day.day);
        final segEnd   = (i == days && !event.isFullDay)
            ? event.endTime
            : DateTime(day.year, day.month, day.day).add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
        final piece = event.copyWith(
          startTime:          segStart,
          endTime:            segEnd,
          effectiveStartTime: event.startTime,
          effectiveEndTime:   event.endTime,
          daysIndex:          days > 0 ? i : null,
        );
        _addDayEvent(day, piece);
      }
    }
  }

  void _addDayEvent(DateTime day, Event event) {
    final key = DateTime(day.year, day.month, day.day);
    dayEvents.putIfAbsent(key, () => []).add(event);
  }

  void clearAll() => dayEvents.clear();

  void removeEvent(Event event) {
    if (event.isMultiDay) {
      var prev = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      while (dayEvents[prev]?.any((e) => e.uniqueId == event.uniqueId) == true) {
        dayEvents[prev]!.removeWhere((e) => e.uniqueId == event.uniqueId);
        prev = prev.subtract(const Duration(days: 1));
      }
      var next = DateTime(event.startTime.year, event.startTime.month, event.startTime.day).add(const Duration(days: 1));
      while (dayEvents[next]?.any((e) => e.uniqueId == event.uniqueId) == true) {
        dayEvents[next]!.removeWhere((e) => e.uniqueId == event.uniqueId);
        next = next.add(const Duration(days: 1));
      }
    } else {
      final key = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      dayEvents[key]?.removeWhere((e) => e.uniqueId == event.uniqueId);
    }
  }

  void updateEvent({required Event oldEvent, required Event newEvent}) {
    removeEvent(oldEvent);
    addEvents([newEvent]);
  }

  void moveEvent(Event event, DateTime newStart, [DateTime? newEnd]) {
    final dur = event.getDuration() ?? const Duration();
    final computedEnd = newEnd ?? newStart.add(dur);
    final updated = event.copyWith(
      startTime: newStart,
      endTime:   computedEnd,
      daysIndex: null,
    );
    updateEvent(oldEvent: event, newEvent: updated);
  }
}