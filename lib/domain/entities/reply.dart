/// 도메인 엔터티: 트윗 리플라이(Reply) 정보
class Reply {
  final String id;
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
}