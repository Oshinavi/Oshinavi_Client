import 'package:flutter/foundation.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/models/user.dart';
import 'package:mediaproject/services/auth/auth_service.dart';
import 'package:mediaproject/services/databases/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthService();
  final _db   = DatabaseService();

  /// 로그인된 사용자의 JWT 토큰 확인 등 AuthService 메서드 사용 가능
  /// (예: 로그아웃, 토큰 만료 체크 등)

  // ─── 외부 유저 프로필 조회 ───────────────────────────────
  Future<UserProfile?> getUserProfile(String tweetId) async {
    return await _db.getUserFromDB(tweetId);
  }

  // ─── 특정 사용자의 최근 트윗 불러오기 ───────────────────────
  List<Post> _allPosts = [];
  List<Post> get allPosts => _allPosts;

  Future<void> loadAllPosts(String tweetId) async {
    final posts = await _db.getAllPostFromDB(tweetId);
    _allPosts = posts;
    notifyListeners();
  }
}