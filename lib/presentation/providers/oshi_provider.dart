import 'package:flutter/foundation.dart';
import 'package:mediaproject/data/datasources/oshi_api.dart';
import 'package:mediaproject/domain/entities/user_profile.dart';

/// ChangeNotifier 기반 오시 프로바이더
/// - 오시 정보 조회, 등록/변경, 삭제
/// - 외부 트위터 사용자 프로필 조회
class OshiProvider extends ChangeNotifier {
  final OshiApi _api = OshiApi();

  /// 외부 트위터 사용자 프로필 조회
  Future<UserProfile?> getUserProfile(String tweetId) async {
    final model = await _api.fetchUserProfile(tweetId);
    return model?.toEntity();
  }

  /// 현재 로그인한 사용자의 오시 정보 조회
  Future<Map<String, dynamic>> getOshi() async {
    return await _api.getOshi();
  }

  /// 오시 등록/변경
  Future<Map<String, dynamic>> registerOshi(String screenName) async {
    return await _api.registerOshi(screenName);
  }

  /// 오시 삭제
  Future<bool> deleteOshi() async {
    return await _api.deleteOshi();
  }
}