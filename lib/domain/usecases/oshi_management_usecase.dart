import '../repositories/oshi_repository.dart';
import '../entities/user_profile.dart';

/// 오시(fan-favorite) 관리 관련 UseCase 클래스
class OshiManagementUseCase {
  final OshiRepository _repository;

  OshiManagementUseCase(this._repository);

  /// 내 오시 정보 조회
  Future<Map<String, dynamic>> getOshi() async {
    return await _repository.getOshi();
  }

  /// 오시 등록/변경
  Future<Map<String, dynamic>> registerOshi(String screenName) async {
    return await _repository.registerOshi(screenName);
  }

  /// 오시 삭제
  Future<bool> deleteOshi() async {
    return await _repository.deleteOshi();
  }

  /// 외부 트위터 사용자 프로필 조회
  Future<UserProfile?> fetchUserProfile(String tweetId) async {
    return await _repository.fetchUserProfile(tweetId);
  }
}