import 'package:flutter/foundation.dart';
import '../../domain/usecases/oshi_management_usecase.dart';
import '../../domain/usecases/fetch_posts_usecase.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/user_profile.dart';

/// HomeViewModel:
/// - 오시 정보 조회
/// - 첫 번째 페이지 및 추가 페이지 게시물 조회
class HomeViewModel extends ChangeNotifier {
  final OshiManagementUseCase _oshiUseCase;
  final FetchPostsUseCase _postUseCase;

  bool isLoading = false;
  String? errorMessage;
  UserProfile? oshiProfile;
  List<Post> posts = [];

  String? _remoteCursor;
  String? _dbCursor;
  bool isLoadingMore = false;

  HomeViewModel({
    required OshiManagementUseCase oshiUseCase,
    required FetchPostsUseCase postUseCase,
  })  : _oshiUseCase = oshiUseCase,
        _postUseCase = postUseCase;

  /// 홈 최초 진입 시, 오시 정보 + 첫 페이지 게시물 로드
  Future<void> loadOshiAndPosts() async {
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1) 오시 정보 가져오기
      final oshiResult = await _oshiUseCase.getOshi();
      if (oshiResult.containsKey('error')) {
        errorMessage = oshiResult['error'] as String;
        posts = [];
      } else {
        final tweetId = oshiResult['oshi_tweet_id'] as String;
        oshiProfile = await _oshiUseCase.fetchUserProfile(tweetId);

        // 2) 첫 페이지 게시물 가져오기
        final firstPage = await _postUseCase.execute(
          screenName: tweetId,
          remoteCursor: null,
          dbCursor: null,
          count: 20,
        );

        posts = firstPage.posts;
        _remoteCursor = firstPage.nextCursor;
        _dbCursor = null;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 스크롤이 맨 아래에 닿으면 다음 페이지 로드
  Future<void> loadMorePosts() async {
    if (isLoadingMore || oshiProfile == null || _remoteCursor == null) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = await _postUseCase.execute(
        screenName: oshiProfile!.tweetId,
        remoteCursor: _remoteCursor,
        dbCursor: _dbCursor,
        count: 20,
      );
      posts.addAll(nextPage.posts);
      _remoteCursor = nextPage.nextCursor;
      // DB 커서가 필요할 경우 nextPage에서 받아 저장
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }
}