import '../entities/reply.dart';

/// Tweet(트윗) 관련 동작을 정의하는 추상 인터페이스
abstract class TweetRepository {
  /// 리플라이 전송 (명명 파라미터)
  Future<Reply> sendReply({
    required String tweetId,
    required String replyText,
  });

  /// 특정 트윗의 리플라이 목록 조회
  Future<List<Reply>> fetchReplies({
    required String tweetId,
  });

  /// AI 자동 생성 리플라이 요청
  Future<String?> generateAutoReply({
    required String tweetId,
    required String tweetText,
    required List<String> contexts,
  });

  /// 리플라이 삭제
  Future<void> deleteReply({
    required String replyId,
  });

  /// 트윗 메타데이터 조회
  Future<Map<String, dynamic>> fetchTweetMetadata({
    required String tweetId,
  });
}