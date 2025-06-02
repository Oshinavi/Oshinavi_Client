import 'package:mediaproject/data/datasources/oshi_api.dart';
import 'package:mediaproject/data/models/user_profile_model.dart';
import 'package:mediaproject/domain/entities/user_profile.dart';
import 'package:mediaproject/domain/repositories/oshi_repository.dart';

/// OshiRepository 인터페이스 구현체
/// - OshiApi를 통해 오시 정보 및 외부 트위터 프로필 조회 수행
class OshiRepositoryImpl implements OshiRepository {
  final OshiApi _api = OshiApi();

  @override
  Future<Map<String, dynamic>> getOshi() async {
    return await _api.getOshi();
  }

  @override
  Future<Map<String, dynamic>> registerOshi(String screenName) async {
    return await _api.registerOshi(screenName);
  }

  @override
  Future<bool> deleteOshi() async {
    return await _api.deleteOshi();
  }

  @override
  Future<UserProfile?> fetchUserProfile(String tweetId) async {
    final UserProfileModel? model = await _api.fetchUserProfile(tweetId);
    if (model == null) return null;
    return model.toEntity();
  }
}