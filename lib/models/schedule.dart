class Schedule {
  /// 서버에서 자동으로 부여되는 ID
  final int id;

  /// 타이틀
  final String title;

  /// 카테고리
  final String category;

  /// 개시시간 (ISO8601 문자열 → DateTime)
  final DateTime startAt;

  /// 종료시간 (ISO8601 문자열 → DateTime)
  final DateTime endAt;

  /// 스케줄 설명
  final String description;

  /// 관련 트위터 스크린네임 (서버→클라이언트 시에는 null 가능)
  final String? relatedTwitterInternalId;

  /// 작성자의 유저 ID
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

  /// JSON → Schedule
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      description: json['description'] as String,
      relatedTwitterInternalId: json['related_twitter_screen_name'] as String?,
      createdByUserId: json['created_by_user_id'] as int,
    );
  }

  /// Schedule → JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'description': description,
      'related_twitter_screen_name': relatedTwitterInternalId,
    };
  }

  /// 필드 일부만 변경하여 새로운 Schedule 객체 생성
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
      relatedTwitterInternalId:
      relatedTwitterInternalId ?? this.relatedTwitterInternalId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }
}