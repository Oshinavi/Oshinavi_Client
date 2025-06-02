import '../datasources/auth_api.dart';
import '../../domain/repositories/auth_repository.dart';

/// AuthRepository 인터페이스 구현체
/// - AuthApi를 통해 실제 HTTP 호출 수행
class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api = AuthApi();

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _api.login(email: email, password: password);
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String cfpassword,
    required String tweetId,
    required String ct0,
    required String authToken,
  }) {
    return _api.signup(
      username: username,
      email: email,
      password: password,
      cfpassword: cfpassword,
      tweetId: tweetId,
      ct0: ct0,
      authToken: authToken,
    );
  }

  @override
  Future<void> logout() {
    return _api.logout();
  }

  @override
  Future<bool> refreshToken() {
    return _api.refreshToken();
  }

  @override
  Future<String?> fetchCurrentTweetId() {
    return _api.fetchCurrentTweetId();
  }
}