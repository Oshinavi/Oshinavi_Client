import 'package:mediaproject/domain/entities/reply.dart';

/// JSON Map을 기반으로 ReplyModel 인스턴스를 생성하고
/// 이를 도메인 엔터티(Reply)로 변환하는 역할 수행
class ReplyModel {
  final String id;
  final String screenName;
  final String userName;
  final String text;
  final String? profileImageUrl;
  final bool isMine;

  ReplyModel({
    required this.id,
    required this.screenName,
    required this.userName,
    required this.text,
    this.profileImageUrl,
    required this.isMine,
  });

  /// JSON(Map) → ReplyModel 객체로 변환하는 팩토리 생성자
  factory ReplyModel.fromMap(Map<String, dynamic> map) {
    return ReplyModel(
      id: (map['id'] as int).toString(),
      screenName: map['screen_name'] as String,
      userName: map['user_name'] as String,
      text: map['text'] as String,
      profileImageUrl: map['profile_image_url'] as String?,
      isMine: map['is_mine'] as bool? ?? false,
    );
  }

  /// ReplyModel → 도메인 엔터티(Reply)로 변환
  Reply toEntity() {
    return Reply(
      id: id,
      screenName: screenName,
      userName: userName,
      text: text,
      profileImageUrl: profileImageUrl,
      isMine: isMine,
    );
  }
}