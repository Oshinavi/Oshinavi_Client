import 'package:flutter/foundation.dart';
import 'package:mediaproject/models/user.dart';
import 'package:mediaproject/services/oshi_service.dart';

class OshiProvider extends ChangeNotifier {
  final _oshi = OshiService();

  Future<UserProfile?> getUserProfile(String tweetId) async {
    return await _oshi.getUserProfile(tweetId);
  }

  Future<Map<String, dynamic>> getOshi() async {
    return await _oshi.getOshi();
  }
}