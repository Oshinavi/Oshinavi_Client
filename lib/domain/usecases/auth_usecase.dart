import '../repositories/auth_repository.dart';

/// 인증(Authentication) 관련 UseCase 클래스
/// - Repository 인터페이스를 통해 실제 데이터 소스 호출
class AuthUseCase {
  final AuthRepository _repository;

  AuthUseCase(this._repository);

  /// 이메일/비밀번호 로그인
  Future<Map<String, dynamic>> login(String email, String password) {
    return _repository.login(email: email, password: password);
  }

  /// 회원가입
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String cfpassword,
    required String tweetId,
    required String ct0,
    required String authToken,
  }) {
    return _repository.signup(
      username: username,
      email: email,
      password: password,
      cfpassword: cfpassword,
      tweetId: tweetId,
      ct0: ct0,
      authToken: authToken,
    );
  }

  /// 로그아웃
  Future<void> logout() {
    return _repository.logout();
  }

  /// 토큰 재발급
  Future<bool> refreshToken() {
    return _repository.refreshToken();
  }

  /// 현재 로그인된 사용자의 Twitter ID 조회
  Future<String?> fetchCurrentTweetId() {
    return _repository.fetchCurrentTweetId();
  }
}