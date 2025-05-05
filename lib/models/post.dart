class Post {
  final String id;                     // 포스트 id
  final String uid;                    // 유저 id (트위터 스크린네임)
  final String username;               // 포스팅 유저 네임
  final DateTime date;                 // 트윗 작성일시

  /// GPT가 추출한 “시작” 일정
  final DateTime? includedStartDate;
  /// GPT가 추출한 “종료” 일정
  final DateTime? includedEndDate;

  final String message;                // 원문 메시지
  final String translatedMessage;      // 번역된 메시지
  final String tweetAbout;             // 분류
  final String? profileImageUrl;       // 프로필 이미지 url

  Post({
    required this.id,
    required this.uid,
    required this.username,
    required this.date,
    this.includedStartDate,
    this.includedEndDate,
    required this.message,
    required this.translatedMessage,
    required this.tweetAbout,
    this.profileImageUrl,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    DateTime? _parse(String? s) =>
        s != null && s.isNotEmpty ? DateTime.tryParse(s) : null;

    return Post(
      id: map['tweet_id']?.toString() ?? '',
      uid: map['tweet_userid'] ?? '',
      username: map['tweet_username'] ?? '',
      date: DateTime.tryParse(map['tweet_date'] ?? '') ?? DateTime.now(),
      includedStartDate:
      _parse(map['tweet_included_start_date'] as String?),
      includedEndDate: _parse(map['tweet_included_end_date'] as String?),
      message: map['tweet_text'] ?? '',
      translatedMessage: map['tweet_translated_text'] ?? '',
      tweetAbout: map['tweet_about'] ?? '',
      profileImageUrl: map['profile_image_url'] as String?,
    );
  }
}