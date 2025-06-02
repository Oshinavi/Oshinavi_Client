import 'package:mediaproject/domain/entities/schedule.dart';

/// JSON(Map)에서 ScheduleModel로 변환하거나
/// 도메인 엔터티(Schedule) ↔ 모델 간 변환을 담당
class ScheduleModel {
  final int id;
  final String title;
  final String category;
  final DateTime startAt;
  final DateTime endAt;
  final String description;
  final String? relatedTwitterInternalId;
  final int createdByUserId;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.startAt,
    required this.endAt,
    required this.description,
    this.relatedTwitterInternalId,
    required this.createdByUserId,
  });

  /// JSON(Map) → ScheduleModel로 변환하는 팩토리 생성자
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      description: json['description'] as String,
      relatedTwitterInternalId:
      json['related_twitter_screen_name'] as String?,
      createdByUserId: json['created_by_user_id'] as int,
    );
  }

  /// ScheduleModel → JSON(Map)으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'description': description,
      'related_twitter_screen_name': relatedTwitterInternalId,
      'created_by_user_id': createdByUserId,
    };
  }

  /// 도메인 엔터티(Schedule) → ScheduleModel로 변환하는 팩토리 생성자
  factory ScheduleModel.fromEntity(Schedule schedule) {
    return ScheduleModel(
      id: schedule.id,
      title: schedule.title,
      category: schedule.category,
      startAt: schedule.startAt,
      endAt: schedule.endAt,
      description: schedule.description,
      relatedTwitterInternalId: schedule.relatedTwitterInternalId,
      createdByUserId: schedule.createdByUserId,
    );
  }

  /// ScheduleModel → 도메인 엔터티(Schedule)로 변환
  Schedule toEntity() {
    return Schedule(
      id: id,
      title: title,
      category: category,
      startAt: startAt,
      endAt: endAt,
      description: description,
      relatedTwitterInternalId: relatedTwitterInternalId,
      createdByUserId: createdByUserId,
    );
  }

  /// 편집 시 copyWith 메서드 제공
  ScheduleModel copyWith({
    int? id,
    String? title,
    String? category,
    DateTime? startAt,
    DateTime? endAt,
    String? description,
    String? relatedTwitterInternalId,
    int? createdByUserId,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      description: description ?? this.description,
      relatedTwitterInternalId:
      relatedTwitterInternalId ?? this.relatedTwitterInternalId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }
}