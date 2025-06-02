/// 게시물 카테고리를 나타내는 enum
enum Category {
  general,
  broadcast,
  radio,
  live,
  album,
  goods,
  video,
  game,
}

/// Category enum에 대한 한글 표시 이름을 제공하는 extension
extension CategoryExtension on Category {
  String get nameKo {
    switch (this) {
      case Category.general:
        return '일반';
      case Category.broadcast:
        return '방송';
      case Category.radio:
        return '라디오';
      case Category.live:
        return '라이브';
      case Category.album:
        return '음반';
      case Category.goods:
        return '굿즈';
      case Category.video:
        return '영상';
      case Category.game:
        return '게임';
    }
  }
}