import '../repositories/database_repository.dart';

/// 게시물 페이징 조회 관련 UseCase 클래스
class FetchPostsUseCase {
  final DatabaseRepository _repository;

  FetchPostsUseCase(this._repository);

  /// 커서 기반 페이징 게시물 조회
  Future<PagedPostsResult> execute({
    required String screenName,
    String? remoteCursor,
    String? dbCursor,
    int count = 20,
  }) async {
    return await _repository.getPostPage(
      screenName: screenName,
      remoteCursor: remoteCursor,
      dbCursor: dbCursor,
      count: count,
    );
  }
}