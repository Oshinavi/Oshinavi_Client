import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/fetch_user_profile_usecase.dart';

/// ProfileViewModel: MVVM 패턴에 따라 UseCase 호출 및 상태 관리 수행
/// - 외부 트위터 사용자 프로필 조회
class ProfileViewModel extends ChangeNotifier {
  final FetchUserProfileUseCase _useCase;

  bool isLoading = false;
  UserProfile? userProfile;
  String? errorMessage;

  // 프로필 캐싱 및 중복 로딩 방지를 위한 상태 관리
  String? _currentTweetId; // 현재 로드된 프로필의 tweetId 저장
  bool _isProfileLoaded = false; // 프로필이 한 번 로드되었는지 확인

  ProfileViewModel({required FetchUserProfileUseCase useCase})
      : _useCase = useCase;

  // 추가 getter들
  bool get isProfileLoaded => _isProfileLoaded;
  String? get currentTweetId => _currentTweetId;

  /// tweetId(스크린네임) 기반으로 외부 사용자 프로필 조회
  /// forceReload가 true이거나, 다른 사용자로 변경된 경우에만 실제 로딩 수행
  Future<void> loadUserProfile(String tweetId, {bool forceReload = false}) async {
    // 이미 같은 사용자 프로필이 로드되었고 강제 갱신이 아닌 경우 스킵
    if (!forceReload && _isProfileLoaded && _currentTweetId == tweetId) {
      return;
    }

    // 다른 사용자로 변경된 경우 기존 프로필 초기화
    if (_currentTweetId != null && _currentTweetId != tweetId) {
      userProfile = null;
      _isProfileLoaded = false;
    }

    isLoading = true;
    errorMessage = null;
    // 새로운 사용자인 경우에만 userProfile을 null로 초기화
    if (_currentTweetId != tweetId) {
      userProfile = null;
    }
    notifyListeners();

    try {
      userProfile = await _useCase.execute(tweetId);
      if (userProfile == null) {
        errorMessage = '유저를 찾을 수 없습니다.';
        _isProfileLoaded = false;
      } else {
        _currentTweetId = tweetId;
        _isProfileLoaded = true;
      }
    } catch (e) {
      errorMessage = e.toString();
      // 에러 시에는 프로필을 null로 설정하지 않고 기존 상태 유지 (같은 사용자인 경우)
      if (_currentTweetId != tweetId) {
        userProfile = null;
        _isProfileLoaded = false;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 프로필 강제 갱신
  Future<void> refreshProfile() async {
    if (_currentTweetId != null) {
      await loadUserProfile(_currentTweetId!, forceReload: true);
    }
  }

  /// 로그아웃 시 프로필 초기화
  void clearProfile() {
    userProfile = null;
    _currentTweetId = null;
    _isProfileLoaded = false;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  /// 사용자 변경 확인 (다른 사용자로 로그인했는지 체크)
  bool isUserChanged(String newTweetId) {
    return _currentTweetId != null && _currentTweetId != newTweetId;
  }
}