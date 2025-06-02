import 'package:flutter/foundation.dart';
import 'package:mediaproject/domain/entities/reply.dart';
import 'package:mediaproject/domain/usecases/fetch_replies_usecase.dart';
import 'package:mediaproject/domain/repositories/tweet_repository.dart';

/// TweetViewModel: MVVM 패턴에 따라 UseCase/Repository 호출 및 상태 관리 수행
/// - 리플라이 목록 로드, 전송, 삭제
/// - AI 자동 리플라이 생성, 메타데이터 조회
class TweetViewModel extends ChangeNotifier {
  final FetchRepliesUseCase _fetchRepliesUseCase;
  final TweetRepository _tweetRepository;

  bool isLoadingReplies = false;
  bool isGeneratingAutoReply = false;
  String? generatedReply;
  String? errorMessage;
  List<Reply> replies = [];

  TweetViewModel({
    required FetchRepliesUseCase fetchRepliesUseCase,
    required TweetRepository tweetRepository,
  })  : _fetchRepliesUseCase = fetchRepliesUseCase,
        _tweetRepository = tweetRepository;

  /// 특정 트윗의 리플라이 목록 로드
  Future<void> loadReplies(String tweetId) async {
    isLoadingReplies = true;
    notifyListeners();
    try {
      replies = await _fetchRepliesUseCase.execute(tweetId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingReplies = false;
      notifyListeners();
    }
  }

  /// 리플라이 전송
  Future<Reply> sendReply(String tweetId, String replyText) async {
    try {
      final newReply = await _tweetRepository.sendReply(tweetId: tweetId, replyText: replyText);
      replies.insert(0, newReply);
      notifyListeners();
      return newReply;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// ▶ AI 자동 생성 리플라이 요청
  Future<String?> generateAutoReply({
    required String tweetId,
    required String tweetText,
    required List<String> contexts,
  }) async {
    isGeneratingAutoReply = true;
    generatedReply = null;
    notifyListeners();
    try {
      generatedReply = await _tweetRepository.generateAutoReply(
        tweetId: tweetId,
        tweetText: tweetText,
        contexts: contexts,
      );
      return generatedReply;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isGeneratingAutoReply = false;
      notifyListeners();
    }
  }

  /// 리플라이 삭제
  Future<void> deleteReply(String replyId) async {
    try {
      await _tweetRepository.deleteReply(replyId: replyId);
      replies.removeWhere((r) => r.id == replyId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 트윗 메타데이터 조회
  Future<Map<String, dynamic>> fetchMetadata(String tweetId) async {
    try {
      return await _tweetRepository.fetchTweetMetadata(tweetId: tweetId);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}