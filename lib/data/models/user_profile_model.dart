import '../../domain/entities/user_profile.dart';

/// JSON(Map)에서 UserProfileModel로 변환하고
/// 도메인 엔터티(UserProfile)로 매핑하는 모델 클래스
class UserProfileModel {
  final String tweetInternalId;
  final String tweetId;
  final String username;
  final String? bio;
  final String? userProfileImageUrl;
  final String? userProfileBannerUrl;
  final int followersCount;
  final int followingCount;

  UserProfileModel({
    required this.tweetInternalId,
    required this.tweetId,
    required this.username,
    this.bio,
    this.userProfileImageUrl,
    this.userProfileBannerUrl,
    required this.followersCount,
    required this.followingCount,
  });

  /// JSON(Map) → UserProfileModel로 변환하는 팩토리 생성자
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      tweetInternalId: (map['twitter_internal_id'] ?? '').toString(),
      tweetId: (map['twitter_id'] as String),
      username: (map['username'] as String),
      bio: map['bio'] as String?,
      userProfileImageUrl: map['profile_image_url'] as String?,
      userProfileBannerUrl: map['profile_banner_url'] as String?,
      followersCount: (map['followers_count'] as int?) ?? 0,
      followingCount: (map['following_count'] as int?) ?? 0,
    );
  }

  /// UserProfileModel → 도메인 엔터티(UserProfile)로 변환
  UserProfile toEntity() {
    return UserProfile(
      tweetInternalId: tweetInternalId,
      tweetId: tweetId,
      username: username,
      bio: bio,
      userProfileImageUrl: userProfileImageUrl,
      userProfileBannerUrl: userProfileBannerUrl,
      followersCount: followersCount,
      followingCount: followingCount,
    );
  }
}