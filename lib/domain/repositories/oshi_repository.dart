import '../entities/user_profile.dart';

/// 오시(fan-favorite) 관련 동작을 정의하는 추상 인터페이스
abstract class OshiRepository {
  /// 내가 설정한 오시 정보 조회 반환 Map { 'oshi_tweet_id': String, 'oshi_username': String } 또는 오류
  Future<Map<String, dynamic>> getOshi();

  /// 오시 등록/변경
  Future<Map<String, dynamic>> registerOshi(String screenName);

  /// 오시 삭제
  Future<bool> deleteOshi();

  /// 오시의 tweetId로 외부 트위터 사용자 프로필 조회
  Future<UserProfile?> fetchUserProfile(String tweetId);
}