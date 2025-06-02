import 'dart:convert';

/// 도메인 엔터티: 트윗(Post) 정보
class Post {
  final String id;
  final String uid;
  final String username;
  final DateTime date;
  final DateTime? includedStartDate;
  final DateTime? includedEndDate;
  final String message;
  final String translatedMessage;
  final String tweetAbout;
  final String? profileImageUrl;
  final List<String> imageUrls;

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
    required this.imageUrls,
  });

  /// Map → Post 엔터티로 변환하는 팩토리 생성자
  factory Post.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDate(String? s) {
      if (s == null || s.isEmpty) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    List<String> _decodeImageUrls(dynamic raw) {
      if (raw == null) return [];
      if (raw is String) {
        try {
          final parsed = jsonDecode(raw) as List<dynamic>;
          return parsed.map((e) => e.toString()).toList();
        } catch (_) {
          return [];
        }
      } else if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return [];
    }

    return Post(
      id: map['tweet_id']?.toString() ?? '',
      uid: map['tweet_userid']?.toString() ?? '',
      username: map['tweet_username']?.toString() ?? '',
      date: DateTime.tryParse(map['tweet_date']?.toString() ?? '') ?? DateTime.now(),
      includedStartDate: _parseDate(map['tweet_included_start_date'] as String?),
      includedEndDate: _parseDate(map['tweet_included_end_date'] as String?),
      message: map['tweet_text']?.toString() ?? '',
      translatedMessage: map['tweet_translated_text']?.toString() ?? '',
      tweetAbout: map['tweet_about']?.toString() ?? '',
      profileImageUrl:
      (map['profile_image_url'] as String?)?.isEmpty == true ? null : map['profile_image_url'] as String?,
      imageUrls: _decodeImageUrls(map['image_urls']),
    );
  }

  /// Post → Map<String, dynamic>으로 변환 (DB/네트워크 전송용)
  Map<String, dynamic> toMap() {
    return {
      'tweet_id': id,
      'tweet_userid': uid,
      'tweet_username': username,
      'tweet_date': date.toIso8601String(),
      'tweet_included_start_date': includedStartDate?.toIso8601String(),
      'tweet_included_end_date': includedEndDate?.toIso8601String(),
      'tweet_text': message,
      'tweet_translated_text': translatedMessage,
      'tweet_about': tweetAbout,
      'profile_image_url': profileImageUrl,
      'image_urls': jsonEncode(imageUrls),
    };
  }
}