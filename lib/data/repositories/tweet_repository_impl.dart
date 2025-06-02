import 'package:mediaproject/data/datasources/tweet_api.dart';
import 'package:mediaproject/domain/entities/reply.dart';
import 'package:mediaproject/domain/repositories/tweet_repository.dart';

/// TweetRepository 인터페이스 구현체
/// - TweetApi를 통해 리플/메타데이터 관련 REST 호출 수행
class TweetRepositoryImpl implements TweetRepository {
  final TweetApi _api = TweetApi();

  @override
  Future<Reply> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final model = await _api.sendReply(tweetId: tweetId, replyText: replyText);
    return model.toEntity();
  }

  @override
  Future<List<Reply>> fetchReplies({required String tweetId}) async {
    final models = await _api.fetchReplies(tweetId: tweetId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<String?> generateAutoReply({
    required String tweetId,
    required String tweetText,
    required List<String> contexts,
  }) async {
    return await _api.generateAutoReply(
      tweetId: tweetId,
      tweetText: tweetText,
      contexts: contexts,
    );
  }

  @override
  Future<void> deleteReply({required String replyId}) async {
    await _api.deleteReply(replyId: replyId);
  }

  @override
  Future<Map<String, dynamic>> fetchTweetMetadata({required String tweetId}) async {
    return await _api.fetchTweetMetadata(tweetId: tweetId);
  }
}