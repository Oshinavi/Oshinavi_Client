// lib/models/reply.dart
class Reply {
  final int id;
  final String screenName;
  final String userName;
  final String text;
  final String? profileImageUrl;
  final bool isMine;

  Reply({
    required this.id,
    required this.screenName,
    required this.userName,
    required this.text,
    this.profileImageUrl,
    required this.isMine,
  });

  factory Reply.fromMap(Map<String, dynamic> m) {
    return Reply(
      id: m['id'] as int,
      screenName: m['screen_name'] as String,
      userName: m['user_name'] as String,
      text: m['text'] as String,
      profileImageUrl: m['profile_image_url'] as String?,
      isMine: m['is_mine'] as bool,
    );
  }
}