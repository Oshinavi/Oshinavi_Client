import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';                // ← 여기
import '../services/auth/auth_service.dart';
import '../services/databases/database_provider.dart';

class UserProfileProvider extends ChangeNotifier {
  final _auth       = AuthService();
  final _dbProvider = DatabaseProvider();

  UserProfile? profile;
  bool isLoading = false;

  /// 한 번만 로드했는지를 기억하는 플래그
  bool _hasLoaded = false;

  Future<void> loadProfile() async {
    // 이미 한 번 로드했다면 아무것도 안 함
    if (_hasLoaded) return;
    _hasLoaded = true;

    final tweetId = await _auth.getCurrentTweetId();
    if (tweetId == null) return;

    isLoading = true;
    notifyListeners();

    profile = await _dbProvider.getUserProfile(tweetId);

    isLoading = false;
    notifyListeners();
  }
}