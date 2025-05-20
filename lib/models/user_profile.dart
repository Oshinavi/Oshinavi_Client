/*

유저 프로필

- 유저 id
- 유저네임
- 바이오
- 프로필 사진

*/

class UserProfile {
  final String tweetInternalId;          // 트위터 내부 id
  final String tweetId;                  // 트위터 id(스크린네임, @cocona_nonaka와 같은 형식)
  final String username;
  final String? bio;
  final String? userProfileImageUrl;
  final String? userProfileBannerUrl;
  final int followersCount;
  final int followingCount;


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

  // Factory constructor to create a UserProfile object from a Map (server response)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      tweetInternalId      : map['tweet_internal_id'] ?? '',
      tweetId              : map['twitter_id']          ?? '',
      username             : map['username']          ?? '',
      bio                  : map['bio'],                       // nullable
      userProfileImageUrl  : map['profile_image_url'],         // nullable
      userProfileBannerUrl : map['profile_banner_url'],        // nullable
      followersCount       : map['followers_count'],
      followingCount       : map['following_count'],
    );
  }

  // Convert UserProfile object to a Map
  Map<String, dynamic> toMap() {
    return {
      'tweet_internal_id' : tweetInternalId,
      'tweet_id'          : tweetId,
      'username'          : username,
      'bio'               : bio,
      'profile_image_url' : userProfileImageUrl,
      'profile_banner_url': userProfileBannerUrl,
      'followers_count'   : followersCount,
      'following_count'   : followingCount,
    };
  }
}