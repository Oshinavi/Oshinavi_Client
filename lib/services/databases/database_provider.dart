// lib/services/databases/database_provider.dart

import 'package:flutter/foundation.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/models/user_profile.dart';
import 'package:mediaproject/services/databases/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final _db = DatabaseService();

  String? _remoteCursor;  // 트위터 웹 스크랩용 커서
  String? _dbCursor;      // DB keyset 페이징 커서

  /// 로그인된 사용자의 JWT 토큰 확인 등 AuthService 메서드 사용 가능
  /// (예: 로그아웃, 토큰 만료 체크 등)

  // ─── 외부 유저 프로필 조회 ───────────────────────────────
  Future<UserProfile?> getUserProfile(String tweetId) async {
    return await _db.getUserFromDB(tweetId);
  }

  // ─── 특정 사용자의 최근 트윗 불러오기 ───────────────────────
  List<Post> _allPosts = [];
  List<Post> get allPosts => _allPosts;

  bool isLoadingMore = false;

  /// 초기 한 페이지 로드 (맨 위 새로고침)
  Future<void> loadAllPosts(String tweetId) async {
    final page = await _db.getPostPageFromDB(
      screenName:   tweetId,
      remoteCursor: null,
      dbCursor:     null,
      count:        20,
    );
    final raw = page['tweets'] as List<dynamic>;
    _allPosts = raw.map((e) => Post.fromMap(e as Map<String, dynamic>)).toList();

    // 두 커서 모두 새로고침 시 다시 1페이지부터 시작
    _remoteCursor = page['next_remote_cursor'] as String?;
    _dbCursor     = page['next_db_cursor']     as String?;
    notifyListeners();
  }

  /// 다음 페이지 로드해서 append (하단 스크롤)
  Future<void> loadMorePosts(String tweetId) async {
    if (isLoadingMore) return;
    // 더 이상 두 커서가 없으면 중단
    if (_remoteCursor == null && _dbCursor == null) return;

    isLoadingMore = true;
    notifyListeners();

    final page = await _db.getPostPageFromDB(
      screenName:   tweetId,
      remoteCursor: _remoteCursor,
      dbCursor:     _dbCursor,
      count:        20,
    );
    final raw  = page['tweets'] as List<dynamic>;
    final more = raw.map((e) => Post.fromMap(e as Map<String, dynamic>)).toList();
    _allPosts.addAll(more);

    // 커서 갱신
    _remoteCursor = page['next_remote_cursor'] as String?;
    _dbCursor     = page['next_db_cursor']     as String?;
    isLoadingMore = false;
    notifyListeners();
  }
}