import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediaproject/models/user.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/constants/api_config.dart';

class DatabaseService {
  final _storage = const FlutterSecureStorage();

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
    // final resp = await http.get(uri, headers: {'Content-Type': 'application/json'});



    // 1) 저장된 JWT 토큰 읽기
    final token = await _storage.read(key: 'jwt_token');
    final headers = <String,String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final resp = await http.get(uri, headers: headers);

    // 디버깅용 RAW JSON 출력
    print('RAW JSON ▶ ${utf8.decode(resp.bodyBytes)}');

    if (resp.statusCode == 200) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      return UserProfile.fromMap(data);
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // 특정 스크린네임의 최근 트윗 목록 조회
  // --------------------------------------------------------------------------
  Future<List<Post>> getAllPostFromDB(String screenName) async {
    // 1) 저장된 JWT 토큰 읽기
    final token = await _storage.read(key: 'jwt_token');

    final uri = Uri.parse(
      '${ApiConfig.host}${ApiConfig.api}/tweets/$screenName',
    );

    // 2) 헤더 구성 (토큰이 있으면 Authorization 포함)
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // 3) 간헐적 500 대응
    Future<http.Response> _attempt() => http.get(uri, headers: headers);
    var resp = await _attempt();
    debugPrint(utf8.decode(resp.bodyBytes), wrapWidth: 2000);
    if (resp.statusCode == 500) {
      await Future.delayed(const Duration(milliseconds: 300));
      resp = await _attempt();
    }

    // 4) 200 이외면 빈 리스트
    if (resp.statusCode != 200) return [];

    // 5) JSON → List<Post>
    try {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(resp.bodyBytes));

      return jsonList.map((e) => Post.fromMap(e)).toList();
    } catch (e) {
      print('❌ JSON 파싱 오류(getAllPost): $e');
      return [];
    }
  }
}