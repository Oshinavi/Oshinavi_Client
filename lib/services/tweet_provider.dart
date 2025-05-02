import 'package:flutter/material.dart';
import 'tweet_service.dart';

class TweetProvider with ChangeNotifier {
  final TweetService _tweetService = TweetService();

  // 리플라이 전송 결과를 외부에서도 확인할 수 있게 상태로 저장
  String? _lastErrorMessage;
  bool _lastReplySuccess = false;

  // 자동 생성된 리플라이 결과
  String? _generatedReply;
  bool _isGeneratingReply = false;

  String? get lastErrorMessage => _lastErrorMessage;
  bool get lastReplySuccess => _lastReplySuccess;
  String? get generatedReply => _generatedReply;
  bool get isGeneratingReply => _isGeneratingReply;

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

  /// 자동 리플라이 생성 요청
  Future<String?> generateAutoReply(String tweetText) async {
    _isGeneratingReply = true;
    _generatedReply = null;
    notifyListeners();

    final result = await _tweetService.generateAutoReply(tweetText);

    _generatedReply = result;
    _isGeneratingReply = false;

    notifyListeners();

    return result;
  }

}