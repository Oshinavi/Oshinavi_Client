/*

유저 프로필

- 유저 id
- 유저네임
- 바이오
- 프로필 사진

*/

class UserProfile {
  final String tweetInternalId;  // tweet_internal_id from Flask
  final String tweetId;  // tweet_id from Flask
  final String username;
  final String bio;
  final String? userProfileImageUrl;
  final String? userProfileBannerUrl;
  // final String? oshiTweetId;  // Optional, oshi_tweet_id from Flask
  // final String? oshiUsername;  // Optional, oshi_username from Flask

  UserProfile({
    required this.tweetInternalId,
    required this.tweetId,
    required this.username,
    required this.bio,
    this.userProfileImageUrl,
    this.userProfileBannerUrl,
    // this.oshiTweetId,
    // this.oshiUsername,
  });

  // Factory constructor to create a UserProfile object from a Map (Flask response)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      tweetInternalId: map['tweet_internal_id'],
      tweetId: map['tweet_id'],
      username: map['username'],
      bio: map['bio'],
      userProfileImageUrl: map['profile_image_url'],
      userProfileBannerUrl: map['profile_banner_url']
      // oshiTweetId: map['oshi_tweet_id'], // this may be null
      // oshiUsername: map['oshi_username'], // this may be null
    );
  }

  // Convert UserProfile object to a Map
  Map<String, dynamic> toMap() {
    return {
      'tweet_internal_id': tweetInternalId,
      'tweet_id': tweetId,
      'username': username,
      'bio': bio,
      // 'oshi_tweet_id': oshiTweetId, // this may be null
      // 'oshi_username': oshiUsername, // this may be null
    };
  }
}