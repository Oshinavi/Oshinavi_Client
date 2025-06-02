import 'package:flutter/foundation.dart';
import '../../domain/usecases/auth_usecase.dart';

/// AuthViewModel: MVVM 패턴에 따라 UseCase 호출 및 상태 관리 수행
/// - 로그인, 회원가입, 로그아웃, 토큰 재발급 등
class AuthViewModel extends ChangeNotifier {
  final AuthUseCase _useCase;

  bool isLoading = false;
  String? errorMessage;

  AuthViewModel({required AuthUseCase useCase}) : _useCase = useCase;

  /// 로그인 처리
  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _useCase.login(email, password);
    isLoading = false;

    if (result.containsKey('error')) {
      errorMessage = result['error'] as String;
    }
    // 성공 시 View에서 화면 전환 처리
    notifyListeners();
  }

  /// ▶ 회원가입 처리
  Future<void> signup({
    required String username,
    required String email,
    required String password,
    required String cfpassword,
    required String tweetId,
    required String ct0,
    required String authToken,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _useCase.signup(
      username: username,
      email: email,
      password: password,
      cfpassword: cfpassword,
      tweetId: tweetId,
      ct0: ct0,
      authToken: authToken,
    );
    isLoading = false;

    if (result.containsKey('error')) {
      errorMessage = result['error'] as String;
    }
    // 성공 시 View에서 화면 전환 처리
    notifyListeners();
  }

  /// 로그아웃 처리
  Future<void> logout() async {
    await _useCase.logout();
    // 필요 시 전역 상태 초기화 등 추가 구현 가능
  }

  /// 현재 로그인된 사용자의 Twitter ID 조회
  Future<String?> fetchCurrentTweetId() {
    return _useCase.fetchCurrentTweetId();
  }

  /// 로그인 상태 확인: 토큰이 유효하면 true 반환
  Future<bool> checkLoginStatus() async {
    final currentTweetId = await _useCase.fetchCurrentTweetId();
    return currentTweetId != null;
  }

  /// 토큰 재발급 시도
  Future<bool> refreshToken() {
    return _useCase.refreshToken();
  }
}