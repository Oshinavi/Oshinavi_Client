class Schedule {
  /// サーバー側で自動採番される予定 ID
  final int id;

  /// タイトル
  final String title;

  /// カテゴリ
  final String category;

  /// 開始日時 (ISO8601 文字列 → DateTime)
  final DateTime startAt;

  /// 終了日時 (ISO8601 文字列 → DateTime)
  final DateTime endAt;

  /// 説明
  final String description;

  /// 관련 트위터 스크린네임 (서버→클라이언트 시에는 null 가능)
  final String? relatedTwitterInternalId;

  /// 作成者のユーザー ID
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
      // null 가능성을 고려
      relatedTwitterInternalId: json['related_twitter_screen_name'] as String?,
      createdByUserId: json['created_by_user_id'] as int,
    );
  }

  /// Schedule → JSON
  /// （PUT や POST のボディに使うとき。バックエンドの期待するキー名に合わせます）
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'description': description,
      // 서버가 기대하는 필드명에 맞춰 screen_name을 보냄
      'related_twitter_screen_name': relatedTwitterInternalId,
    };
  }
}