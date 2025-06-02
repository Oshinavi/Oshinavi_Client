import 'package:flutter/foundation.dart';
import '../../domain/usecases/oshi_management_usecase.dart';
import '../../domain/entities/user_profile.dart';

/// OshiViewModel: UseCase 호출 및 상태 관리 수행
/// - 오시 정보 조회, 등록/변경, 삭제
/// - OshiProfile(트위터 사용자 프로필) 조회
class OshiViewModel extends ChangeNotifier {
  final OshiManagementUseCase _useCase;

  bool isLoading = false;
  String? errorMessage;
  String? currentOshiTweetId;
  UserProfile? oshiProfile;

  OshiViewModel({required OshiManagementUseCase useCase}) : _useCase = useCase;

  /// 오시 정보 로드
  Future<void> loadOshi() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _useCase.getOshi();
    if (result.containsKey('error')) {
      errorMessage = result['error'] as String;
    } else {
      currentOshiTweetId = result['oshi_tweet_id'] as String;
      oshiProfile = await _useCase.fetchUserProfile(currentOshiTweetId!);
    }

    isLoading = false;
    notifyListeners();
  }

  /// 오시 등록/변경
  Future<void> registerOshi(String tweetId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _useCase.registerOshi(tweetId);
    if (result.containsKey('error')) {
      errorMessage = result['error'] as String;
    } else {
      currentOshiTweetId = tweetId;
      oshiProfile = await _useCase.fetchUserProfile(tweetId);
    }

    isLoading = false;
    notifyListeners();
  }

  /// 오시 삭제
  Future<void> deleteOshi() async {
    final success = await _useCase.deleteOshi();
    if (success) {
      currentOshiTweetId = null;
      oshiProfile = null;
    } else {
      errorMessage = '오시 삭제 실패';
    }
    notifyListeners();
  }
}