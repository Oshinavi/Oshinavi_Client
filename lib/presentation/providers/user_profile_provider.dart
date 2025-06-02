import 'package:flutter/foundation.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../../domain/usecases/fetch_user_profile_usecase.dart';
import '../../domain/entities/user_profile.dart';

/// ChangeNotifier 기반 사용자 프로필 프로바이더
/// - 로그인된 사용자의 tweetId(스크린네임) 조회 후 프로필 로드
class UserProfileProvider extends ChangeNotifier {
  final AuthUseCase _authUseCase;
  final FetchUserProfileUseCase _fetchProfileUseCase;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _hasLoaded = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  UserProfileProvider({
    required AuthUseCase authUseCase,
    required FetchUserProfileUseCase fetchProfileUseCase,
  })  : _authUseCase = authUseCase,
        _fetchProfileUseCase = fetchProfileUseCase;

  /// 한 번만 프로필을 로드하도록 플래그 체크
  Future<void> loadProfile() async {
    if (_hasLoaded) return;
    _hasLoaded = true;

    final tweetId = await _authUseCase.fetchCurrentTweetId();
    if (tweetId == null) return;

    _isLoading = true;
    notifyListeners();

    _profile = await _fetchProfileUseCase.execute(tweetId);
    _isLoading = false;
    notifyListeners();
  }

  /// 프로필 초기화
  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}