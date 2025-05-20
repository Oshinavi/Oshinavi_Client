import 'package:flutter/material.dart';
import '../models/reply.dart';
import 'tweet_service.dart';

class TweetProvider with ChangeNotifier {
  final TweetService _tweetService = TweetService();

  List<Reply> _allReplies = [];
  List<Reply> get allReplies => _allReplies;

  String?  _lastErrorMessage;
  bool     _lastReplySuccess = false;
  String?  _generatedReply;
  bool     _isGeneratingReply = false;

  String? get lastErrorMessage  => _lastErrorMessage;
  bool    get lastReplySuccess  => _lastReplySuccess;
  String? get generatedReply    => _generatedReply;
  bool    get isGeneratingReply => _isGeneratingReply;

  /// 기존: 리플라이 전송
  Future<Reply> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final data = await _tweetService.sendReply(
      tweetId: tweetId,
      replyText: replyText,
    );
    // Map → Reply 모델로 변환
    final newReply = Reply.fromMap(data);
    return newReply;
  }

  /// 기존: 자동 리플라이 생성
  Future<String?> generateAutoReply({
    required String tweetId,
    required String tweetText,
    required List<String> contexts,
  }) async {
    _isGeneratingReply = true;
    _generatedReply    = null;
    notifyListeners();

    final reply = await _tweetService.generateAutoReply(
      tweetId: tweetId,
      tweetText: tweetText,
      contexts: contexts,
    );

    _generatedReply    = reply;
    _isGeneratingReply = false;
    notifyListeners();
    return reply;
  }

  /// 삭제된 리플라이 서버 호출 + 로컬에서 제거
  Future<void> deleteReply({
    required String replyId,
  }) async {
    await _tweetService.deleteReply(replyId: replyId);
    _allReplies.removeWhere((r) => r.id.toString() == replyId);
    notifyListeners();
  }

  /// 신규: 분류·일정 메타데이터(fetch)
  Future<Map<String, dynamic>> fetchTweetMetadata(String tweetId) async {
    try {
      final meta = await _tweetService.fetchTweetMetadata(tweetId: tweetId);
      _lastErrorMessage = null;
      return meta;
    } catch (e) {
      _lastErrorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  Future<List<Reply>> fetchReplies({ required String tweetId }) async {
    // 1) 서버에서 조회
    final raw = await _tweetService.fetchReplies(tweetId: tweetId);
    // 2) Map → Reply 모델 변환
    final list = raw.map((m) => Reply.fromMap(m)).toList();
    // 3) 로컬 상태에 저장
    _allReplies = list;
    // 4) 화면 갱신
    notifyListeners();
    return list;
  }
}