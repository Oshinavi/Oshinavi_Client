/// 도메인 엔터티: 사용자 프로필(UserProfile) 정보
class UserProfile {
  final String tweetInternalId;       // DB 상의 고유 ID (문자열)
  final String tweetId;               // 트위터 스크린네임
  final String username;              // 사용자 표시 이름
  final String? bio;                  // (선택) 소개글
  final String? userProfileImageUrl;  // (선택) 프로필 사진 URL
  final String? userProfileBannerUrl; // (선택) 배너 사진 URL
  final int followersCount;           // 팔로워 수
  final int followingCount;           // 팔로잉 수

  UserProfile({
    required this.tweetInternalId,
    required this.tweetId,
    required this.username,
    this.bio,
    this.userProfileImageUrl,
    this.userProfileBannerUrl,
    required this.followersCount,
    required this.followingCount,
  });

  /// JSON(Map) → UserProfile 엔터티 변환용 팩토리 생성자
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      tweetInternalId: (map['id'] ?? '').toString(),
      tweetId: (map['tweet_id'] as String),
      username: (map['username'] as String),
      bio: map['bio'] as String?,
      userProfileImageUrl: map['profile_image_url'] as String?,
      userProfileBannerUrl: map['profile_banner_url'] as String?,
      followersCount: (map['followers_count'] as int?) ?? 0,
      followingCount: (map['following_count'] as int?) ?? 0,
    );
  }

  /// 엔터티 → Map<String, dynamic> 변환 메서드
  Map<String, dynamic> toMap() {
    return {
      'id': tweetInternalId,
      'tweet_id': tweetId,
      'username': username,
      'bio': bio,
      'profile_image_url': userProfileImageUrl,
      'profile_banner_url': userProfileBannerUrl,
      'followers_count': followersCount,
      'following_count': followingCount,
    };
  }
}