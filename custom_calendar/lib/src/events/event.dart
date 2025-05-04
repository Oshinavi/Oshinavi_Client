import 'package:flutter/material.dart';

class Event {
  final String? uniqueId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? title;
  final String? description;
  final Color color;
  final Color textColor;
  final int? columnIndex;
  final dynamic data;

  final DateTime? effectiveStartTime;
  final DateTime? effectiveEndTime;
  final int? daysIndex;
  final bool isFullDay;
  final bool isMultiDay;

  Event({
    this.uniqueId,
    required this.startTime,
    this.endTime,
    this.title,
    this.description,
    required this.color,
    this.textColor = Colors.white,
    this.columnIndex,
    this.data,
    this.effectiveStartTime,
    this.effectiveEndTime,
    this.daysIndex,
    this.isFullDay = false,
    this.isMultiDay = false,
  });

  Event copyWith({
    String? uniqueId,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    String? description,
    Color? color,
    Color? textColor,
    int? columnIndex,
    dynamic data,
    DateTime? effectiveStartTime,
    DateTime? effectiveEndTime,
    int? daysIndex,
    bool? isFullDay,
    bool? isMultiDay,
  }) {
    return Event(
      uniqueId: uniqueId ?? this.uniqueId, // ✅ 고유 ID 유지
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      textColor: textColor ?? this.textColor,
      columnIndex: columnIndex ?? this.columnIndex,
      data: data ?? this.data,
      effectiveStartTime: effectiveStartTime ?? this.effectiveStartTime,
      effectiveEndTime: effectiveEndTime ?? this.effectiveEndTime,
      daysIndex: daysIndex ?? this.daysIndex,
      isFullDay: isFullDay ?? this.isFullDay,
      isMultiDay: isMultiDay ?? this.isMultiDay,
    );
  }

  Duration? getDuration() {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }
}