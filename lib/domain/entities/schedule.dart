/// 도메인 엔터티: 스케줄(Schedule) 정보
class Schedule {
  final int id;
  final String title;
  final String category;
  final DateTime startAt;
  final DateTime endAt;
  final String description;
  final String? relatedTwitterInternalId;
  final int createdByUserId;

  Schedule({
    required this.id,
    required this.title,
    required this.category,
    required this.startAt,
    required this.endAt,
    required this.description,
    this.relatedTwitterInternalId,
    required this.createdByUserId,
  });

  /// 편집 시 사용 가능한 copyWith 메서드
  Schedule copyWith({
    int? id,
    String? title,
    String? category,
    DateTime? startAt,
    DateTime? endAt,
    String? description,
    String? relatedTwitterInternalId,
    int? createdByUserId,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      description: description ?? this.description,
      relatedTwitterInternalId: relatedTwitterInternalId ?? this.relatedTwitterInternalId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }
}