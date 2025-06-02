/// 인증 관련 동작을 정의하는 추상 인터페이스
abstract class AuthRepository {
  /// 로그인 API 호출
  /// - 성공 시: { "access_token": "...", "statusCode": 200, ... }
  /// - 실패 시: { "statusCode": <코드>, "error": "<에러 메시지>" }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  /// 회원가입 API 호출
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String cfpassword,
    required String tweetId,
    required String ct0,
    required String authToken,
  });

  /// 로그아웃 API 호출
  Future<void> logout();

  /// 토큰 재발급 API 호출
  /// - 성공 시: true 실패 시: false
  Future<bool> refreshToken();

  /// 현재 로그인된 사용자의 Twitter ID(스크린네임) 조회
  Future<String?> fetchCurrentTweetId();
}