import 'package:flutter/material.dart';
import 'package:mediaproject/data/models/reply_model.dart';
import 'package:mediaproject/data/datasources/tweet_api.dart';

/// ChangeNotifier 기반 Tweet 관련 프로바이더
/// - 리플 전송, 조회, 자동 생성, 삭제, 메타데이터 조회
class TweetProvider with ChangeNotifier {
  final TweetApi _tweetApi = TweetApi();

  List<ReplyModel> _allReplies = [];
  List<ReplyModel> get allReplies => List.unmodifiable(_allReplies);

  String? _lastErrorMessage;
  bool _isGeneratingReply = false;
  String? _generatedReply;

  String? get lastErrorMessage => _lastErrorMessage;
  bool get isGeneratingReply => _isGeneratingReply;
  String? get generatedReply => _generatedReply;

  /// 리플 전송
  Future<ReplyModel> sendReply({
    required String tweetId,
    required String replyText,
  }) async {
    final newReply = await _tweetApi.sendReply(tweetId: tweetId, replyText: replyText);
    _allReplies.insert(0, newReply);
    notifyListeners();
    return newReply;
  }

  /// 리플 목록 조회
  Future<List<ReplyModel>> fetchReplies({required String tweetId}) async {
    final list = await _tweetApi.fetchReplies(tweetId: tweetId);
    _allReplies = list;
    notifyListeners();
    return list;
  }

  /// 자동 리플 생성
  Future<String?> generateAutoReply({
    required String tweetId,
    required String tweetText,
    required List<String> contexts,
  }) async {
    _isGeneratingReply = true;
    _generatedReply = null;
    notifyListeners();

    try {
      _generatedReply = await _tweetApi.generateAutoReply(
        tweetId: tweetId,
        tweetText: tweetText,
        contexts: contexts,
      );
      return _generatedReply;
    } catch (e) {
      _lastErrorMessage = e.toString();
      return null;
    } finally {
      _isGeneratingReply = false;
      notifyListeners();
    }
  }

  /// 리플 삭제
  Future<void> deleteReply({required String replyId}) async {
    await _tweetApi.deleteReply(replyId: replyId);
    _allReplies.removeWhere((r) => r.id == replyId);
    notifyListeners();
  }

  /// 트윗 메타데이터 조회
  Future<Map<String, dynamic>> fetchTweetMetadata({required String tweetId}) async {
    try {
      final meta = await _tweetApi.fetchTweetMetadata(tweetId: tweetId);
      _lastErrorMessage = null;
      return meta;
    } catch (e) {
      _lastErrorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}