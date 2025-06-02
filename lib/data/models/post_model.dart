import 'package:mediaproject/domain/entities/post.dart';

/// 서버로부터 받은 JSON Map을 기반으로 PostModel 인스턴스를 생성하고
/// 이를 도메인 엔터티(Post)로 변환하는 역할 수행
class PostModel {
  final String id;
  final String uid;
  final String username;
  final String profileImageUrl;
  final String message;
  final String? translatedMessage;
  final DateTime date;
  final List<String> imageUrls;

  PostModel({
    required this.id,
    required this.uid,
    required this.username,
    required this.profileImageUrl,
    required this.message,
    this.translatedMessage,
    required this.date,
    required this.imageUrls,
  });

  /// JSON(Map) → PostModel 객체로 변환하는 팩토리 생성자
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['tweet_id'].toString(),
      uid: map['tweet_userid'] as String,
      username: map['tweet_username'] as String,
      profileImageUrl: (map['profile_image_url'] as String?) ?? '',
      message: map['tweet_text'] as String,
      translatedMessage: map['tweet_translated_text'] as String?,
      date: DateTime.parse(map['tweet_date'] as String),
      imageUrls: (map['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
    );
  }

  /// PostModel → 도메인 엔터티(Post)로 변환
  Post toEntity() {
    return Post(
      id: id,
      uid: uid,
      username: username,
      date: date,
      includedStartDate: null, // 모델에 포함된 일정 정보가 없으므로 null
      includedEndDate: null,
      message: message,
      translatedMessage: translatedMessage ?? '',
      tweetAbout: '',
      profileImageUrl:
      profileImageUrl.trim().isEmpty ? null : profileImageUrl,
      imageUrls: imageUrls,
    );
  }
}