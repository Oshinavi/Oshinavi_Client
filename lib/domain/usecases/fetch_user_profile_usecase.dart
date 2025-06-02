import '../entities/user_profile.dart';
import '../repositories/database_repository.dart';

/// 사용자 프로필 조회 관련 UseCase 클래스
class FetchUserProfileUseCase {
  final DatabaseRepository _repository;

  FetchUserProfileUseCase(this._repository);

  /// tweetId(스크린네임) 기반으로 사용자 프로필 조회
  Future<UserProfile?> execute(String tweetId) {
    return _repository.getUserProfile(tweetId);
  }
}