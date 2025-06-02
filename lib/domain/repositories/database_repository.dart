import '../entities/post.dart';
import '../entities/user_profile.dart';

/// 커서(cursor) 기반으로 페이징된 게시물 결과를 나타내는 DTO
/// - posts: 조회된 Post 목록
/// - nextCursor: 다음 페이지 조회용 cursor (null이면 더 이상 없음)
class PagedPostsResult {
  final List<Post> posts;
  final String? nextCursor;

  PagedPostsResult({
    required this.posts,
    required this.nextCursor,
  });
}

/// 데이터베이스 및 외부 트위터 API 호출을 통해 데이터를 가져오는 추상 인터페이스
abstract class DatabaseRepository {
  /// 특정 tweetId(user)의 프로필 조회
  Future<UserProfile?> getUserProfile(String tweetId);

  /// 커서(cursor) 기반 페이징된 게시물 페이지 조회
  Future<PagedPostsResult> getPostPage({
    required String screenName,
    String? remoteCursor,
    String? dbCursor,
    int count,
  });

  /// 커서 없이 한꺼번에 모든 게시물 가져오기
  Future<List<Post>> getAllPosts(String screenName);
}