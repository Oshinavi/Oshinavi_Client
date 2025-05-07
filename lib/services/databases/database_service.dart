import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediaproject/models/user.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/constants/api_config.dart';

class DatabaseService {
  // --------------------------------------------------------------------------
  // 회원가입
  // --------------------------------------------------------------------------
  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String cfpassword,
    required String tweetId,
  }) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/auth/signup');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username':   username,
        'email':      email,
        'password':   password,
        'cfpassword': cfpassword,
        'tweet_id':   tweetId,
      }),
    );
    return resp.statusCode == 201;
  }

  // --------------------------------------------------------------------------
  // 외부 트위터 유저 프로필 조회
  // --------------------------------------------------------------------------
  Future<UserProfile?> getUserFromDB(String tweetId) async {
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/users/profile?tweet_id=$tweetId');
    final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});

    // ① 여기에 추가 ── 백엔드가 보내 준 JSON 그대로 보기
    print('RAW JSON ▶ ${utf8.decode(resp.bodyBytes)}');

    if (resp.statusCode == 200) {
      final data = jsonDecode(
          utf8.decode(resp.bodyBytes)            // ✅
      );
      return UserProfile.fromMap(data);
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // 특정 스크린네임의 최근 트윗 목록 조회
  // --------------------------------------------------------------------------
  Future<List<Post>> getAllPostFromDB(String screenName) async {
    final uri = Uri.parse(
        '${ApiConfig.host}${ApiConfig.api}/tweets/$screenName');

    // 간헐적 500 대응
    Future<http.Response> _attempt() => http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    var resp = await _attempt();
    if (resp.statusCode == 500) {
      await Future.delayed(const Duration(milliseconds: 300));
      resp = await _attempt();
    }
    if (resp.statusCode != 200) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(
          utf8.decode(resp.bodyBytes)
      );
      return jsonList.map((e) => Post.fromMap(e)).toList();
    } catch (e) {
      print('❌ JSON 파싱 오류(getAllPost): $e');
      return [];
    }
  }
}