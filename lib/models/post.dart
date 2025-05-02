class Post{
  final String id; // 포스트 id
  final String uid; //유저 id
  final String username; //포스팅 유저 네임
  final DateTime date; //타임스탬프
  final DateTime? includedDate; //트윗 메시지에 들어있는 날짜 정보
  final String message; //트윗 메시지
  final String translatedMessage; //번역 메시지
  final String tweetAbout; //트윗 주제
  final String? profileImageUrl; //프로필 이미지 url
  // final int likeCount; //좋아요 수
  // final List<String> likeBy; //좋아요를 누른 유저 id 목록

  Post({
    required this.id,
    required this.uid,
    required this.username,
    required this.date,
    required this.includedDate,
    required this.message,
    required this.translatedMessage,
    required this.tweetAbout,
    this.profileImageUrl,
    // required this.likeCount,
    // required this.likeBy,
  });

  // factory Post.fromMap(Map<String, dynamic> map) {
  //   return Post(
  //     id: map['tweet_id'].toString(),
  //     uid: map['tweet_userid'],
  //     username: map['tweet_username'],
  //     date: DateTime.parse(map['tweet_date']),
  //     includedDate: map['tweet_included_date'] != null
  //         ? DateTime.tryParse(map['tweet_included_date'])
  //         : null, // ❗ 명확히 null 처리
  //     message: map['tweet_text'],
  //     translatedMessage: map['tweet_translated_text'],
  //     tweetAbout: map['tweet_about'],
  //   );
  // }
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['tweet_id']?.toString() ?? '', // null-safe 변환
      uid: map['tweet_userid'] ?? '',
      username: map['tweet_username'] ?? '',
      date: DateTime.tryParse(map['tweet_date'] ?? '') ?? DateTime.now(),
      includedDate: (map['tweet_included_date'] is String && map['tweet_included_date'].isNotEmpty)
          ? DateTime.tryParse(map['tweet_included_date'])
          : null,
      message: map['tweet_text'] ?? '',
      translatedMessage: map['tweet_translated_text'] ?? '',
      tweetAbout: map['tweet_about'] ?? '',
      profileImageUrl: map['profile_image_url'],
    );
  }
}