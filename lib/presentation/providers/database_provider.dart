import 'package:flutter/foundation.dart';
import 'package:mediaproject/domain/entities/post.dart';
import 'package:mediaproject/domain/entities/user_profile.dart';
import 'package:mediaproject/data/datasources/database_api.dart';
import 'package:mediaproject/data/models/post_model.dart';

/// ChangeNotifier 기반 데이터베이스 프로바이더
/// - 첫 페이지 게시물 로드 및 추가 페이지 로드
/// - 외부 트위터 사용자 프로필 조회
class DatabaseProvider extends ChangeNotifier {
  final DatabaseApi _dbApi = DatabaseApi();

  String? _remoteCursor; // 트위터 스크랩 “다음 커서”
  String? _dbCursor;     // DB keyset 페이징 커서

  final List<Post> _allPosts = [];
  List<Post> get allPosts => List.unmodifiable(_allPosts);

  bool isLoadingMore = false;

  /// 첫 페이지(맨 위 새로고침) 로드
  Future<void> loadAllPosts(String tweetId) async {
    final page = await _dbApi.fetchPostPage(
      screenName: tweetId,
      remoteCursor: null,
      dbCursor: null,
      count: 20,
    );

    final raw = page['tweets'] as List<dynamic>;
    _allPosts.clear();
    for (final e in raw) {
      final model = PostModel.fromMap(e as Map<String, dynamic>);
      _allPosts.add(model.toEntity());
    }

    _remoteCursor = page['next_remote_cursor'] as String?;
    _dbCursor = page['next_db_cursor'] as String?;
    notifyListeners();
  }

  /// 다음 페이지 로드 (하단 스크롤 시 호출)
  Future<void> loadMorePosts(String tweetId) async {
    if (isLoadingMore || (_remoteCursor == null && _dbCursor == null)) return;

    isLoadingMore = true;
    notifyListeners();

    final page = await _dbApi.fetchPostPage(
      screenName: tweetId,
      remoteCursor: _remoteCursor,
      dbCursor: _dbCursor,
      count: 20,
    );

    final raw = page['tweets'] as List<dynamic>;
    for (final e in raw) {
      final model = PostModel.fromMap(e as Map<String, dynamic>);
      _allPosts.add(model.toEntity());
    }

    _remoteCursor = page['next_remote_cursor'] as String?;
    _dbCursor = page['next_db_cursor'] as String?;
    isLoadingMore = false;
    notifyListeners();
  }

  /// 외부 트위터 사용자 프로필 조회
  Future<UserProfile?> getUserProfile(String tweetId) async {
    final model = await _dbApi.fetchUserProfile(tweetId);
    return model?.toEntity();
  }
}