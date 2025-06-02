import '../entities/reply.dart';
import '../repositories/tweet_repository.dart';

/// 리플라이 조회 관련 UseCase 클래스
class FetchRepliesUseCase {
  final TweetRepository _repository;

  FetchRepliesUseCase(this._repository);

  /// 특정 트윗의 리플라이 목록 조회
  Future<List<Reply>> execute(String tweetId) async {
    return await _repository.fetchReplies(tweetId: tweetId);
  }
}