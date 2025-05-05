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

  Future<bool> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final result = await _tweetService.sendReply(
      tweetId: tweetId,
      replyText: replyText,
    );
    _lastReplySuccess  = result;
    _lastErrorMessage  = result ? null : '리플라이 전송에 실패했습니다.';
    notifyListeners();
    return result;
  }

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
}