import 'package:mediaproject/data/datasources/database_api.dart';
import 'package:mediaproject/data/models/post_model.dart';
import 'package:mediaproject/data/models/user_profile_model.dart';
import 'package:mediaproject/domain/entities/post.dart';
import 'package:mediaproject/domain/entities/user_profile.dart';
import 'package:mediaproject/domain/repositories/database_repository.dart';

/// DatabaseRepository 인터페이스 구현체
/// - DatabaseApi를 통해 외부 REST 호출 수행
/// - 반환된 모델을 도메인 엔터티로 변환
class DatabaseRepositoryImpl implements DatabaseRepository {
  final DatabaseApi _api = DatabaseApi();

  @override
  Future<UserProfile?> getUserProfile(String tweetId) async {
    final UserProfileModel? model = await _api.fetchUserProfile(tweetId);
    if (model == null) return null;
    return model.toEntity();
  }

  @override
  Future<PagedPostsResult> getPostPage({
    required String screenName,
    String? remoteCursor,
    String? dbCursor,
    int count = 20,
  }) async {
    final Map<String, dynamic> rawResponse = await _api.fetchPostPage(
      screenName: screenName,
      remoteCursor: remoteCursor,
      dbCursor: dbCursor,
      count: count,
    );

    final rawItems = rawResponse['tweets'] as List<dynamic>;
    final List<PostModel> models =
    rawItems.map((m) => PostModel.fromMap(m as Map<String, dynamic>)).toList();
    final posts = models.map((m) => m.toEntity()).toList();

    return PagedPostsResult(
      posts: posts,
      nextCursor: rawResponse['next_remote_cursor'] as String?,
    );
  }

  @override
  Future<List<Post>> getAllPosts(String screenName) async {
    final models = await _api.fetchAllPosts(screenName);
    return models.map((m) => m.toEntity()).toList();
  }
}