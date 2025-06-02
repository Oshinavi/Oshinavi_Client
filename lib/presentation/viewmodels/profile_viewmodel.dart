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

  ProfileViewModel({required FetchUserProfileUseCase useCase})
      : _useCase = useCase;

  /// tweetId(스크린네임) 기반으로 외부 사용자 프로필 조회
  Future<void> loadUserProfile(String tweetId) async {
    isLoading = true;
    errorMessage = null;
    userProfile = null;
    notifyListeners();

    try {
      userProfile = await _useCase.execute(tweetId);
      if (userProfile == null) {
        errorMessage = '유저를 찾을 수 없습니다.';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}