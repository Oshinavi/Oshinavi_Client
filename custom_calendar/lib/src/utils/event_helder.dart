import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:custom_calendar/custom_calendar.dart';
import '../utils/extension.dart';

/// 주 단위에서 보여줄 이벤트를 계산하여 각 요일에 맞게 배치하는 함수
List<List<Event?>> getShowedWeekEvents(
    List<List<Event>?> weekEvents,
    int maxEventsShowed,
    ) {
  var sortedMultiDayEvents = getWeekMultiDaysEventsSortedMap(weekEvents);

  // 단일 일정 먼저 배치
  List<List<Event?>> daysEventsList = List.generate(7, (index) {
    var events = (weekEvents[index] ?? []).where((e) => !e.isMultiDay);
    return List.generate(maxEventsShowed, (i) => events.getOrNull(i));
  });

  // 멀티데이 이벤트 배치
  for (var multiDayEvents in sortedMultiDayEvents.values) {
    var firstDayIndex = multiDayEvents.keys.first;
    var firstDayEvents = daysEventsList[firstDayIndex];
    var eventToPlace = multiDayEvents.values.first;

    int index = 0;
    while (index < firstDayEvents.length && firstDayEvents[index] != null) {
      if (eventToPlace.startTime.isAfter(firstDayEvents[index]!.startTime)) {
        index++;
      } else {
        break;
      }
    }

    if (index < maxEventsShowed) {
      for (var entry in multiDayEvents.entries) {
        daysEventsList[entry.key].insert(index, entry.value);
      }
    }
  }

  return daysEventsList;
}

/// 주 단위에서 멀티데이 이벤트만 추출하고 정렬된 Map 으로 반환
SplayTreeMap<String, Map<int, Event>> getWeekMultiDaysEventsSortedMap(
    List<List<Event>?> weekEvents) {
  Map<String, Map<int, Event>> multiDaysEventsMap = {};

  for (int day = 0; day < 7; day++) {
    var multiDayEvents = weekEvents[day]?.where((e) => e.isMultiDay);
    for (var event in (multiDayEvents ?? <Event>[])) {
      if (event.uniqueId == null) continue; // 안전 체크
      multiDaysEventsMap[event.uniqueId!] = {
        ...multiDaysEventsMap[event.uniqueId!] ?? {},
        day: event
      };
    }
  }

  final sortedMap = SplayTreeMap<String, Map<int, Event>>.from(
    multiDaysEventsMap,
        (a, b) {
      final eventA = multiDaysEventsMap[a]!.values.first;
      final eventB = multiDaysEventsMap[b]!.values.first;
      return eventA.startTime.compareTo(eventB.startTime);
    },
  );

  return sortedMap;
}

/// 두 날짜 사이의 모든 날짜 리스트를 반환
List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}
