import 'package:flutter/material.dart';
import 'tweet_service.dart';

class TweetProvider with ChangeNotifier {
  final TweetService _tweetService = TweetService();

  String?  _lastErrorMessage;
  bool     _lastReplySuccess = false;
  String?  _generatedReply;
  bool     _isGeneratingReply = false;

  String? get lastErrorMessage  => _lastErrorMessage;
  bool    get lastReplySuccess  => _lastReplySuccess;
  String? get generatedReply    => _generatedReply;
  bool    get isGeneratingReply => _isGeneratingReply;

  /// 기존: 리플라이 전송
  Future<bool> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final result = await _tweetService.sendReply(
      tweetId: tweetId,
      replyText: replyText,
    );
    _lastReplySuccess = result;
    _lastErrorMessage = result ? null : '리플라이 전송에 실패했습니다.';
    notifyListeners();
    return result;
  }

  /// 기존: 자동 리플라이 생성
  Future<String?> generateAutoReply(String tweetText) async {
    _isGeneratingReply = true;
    _generatedReply    = null;
    notifyListeners();

    final reply = await _tweetService.generateAutoReply(tweetText);
    _generatedReply    = reply;
    _isGeneratingReply = false;
    notifyListeners();
    return reply;
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
}