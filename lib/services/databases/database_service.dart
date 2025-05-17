// lib/services/databases/database_service.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mediaproject/models/user_profile.dart';
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
    final token = await _storage.read(key: 'jwt_token');
    final headers = <String,String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final resp = await http.get(uri, headers: headers);

    print('RAW JSON ▶ ${utf8.decode(resp.bodyBytes)}');

    if (resp.statusCode == 200) {
      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      return UserProfile.fromMap(data);
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // 특정 스크린네임의 최근 트윗 목록 조회 (페이징 없이 전체 리스트)
  // --------------------------------------------------------------------------
  Future<List<Post>> getAllPostFromDB(String screenName) async {
    final token = await _storage.read(key: 'jwt_token');
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/$screenName');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(uri, headers: headers);
    debugPrint('▶ HTTP ${resp.statusCode}: ${resp.body}');

    if (resp.statusCode != 200) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(resp.bodyBytes));
      return jsonList.map((e) => Post.fromMap(e)).toList();
    } catch (e) {
      print('❌ JSON 파싱 오류(getAllPost): $e');
      return [];
    }
  }

  // --------------------------------------------------------------------------
  // 특정 스크린네임의 트윗 페이지 단위 조회 (cursor 기반 페이징)
  // --------------------------------------------------------------------------
  Future<Map<String, dynamic>> getPostPageFromDB({
    required String screenName,
    String? remoteCursor,
    String? dbCursor,
    int count = 20,
  }) async {
    final token = await _storage.read(key: 'jwt_token');
    // build uri with both cursors + count
    var uri = Uri.parse('${ApiConfig.host}${ApiConfig.api}/tweets/$screenName');
    final qp = <String,String>{
      'count': '$count',
      if (remoteCursor != null) 'remote_cursor': remoteCursor,
      if (dbCursor     != null) 'db_cursor':     dbCursor,
    };
    uri = uri.replace(queryParameters: qp);

    debugPrint('▶ fetch tweets URI: $uri');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final resp = await http.get(uri, headers: headers);
    debugPrint('▶ HTTP ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode != 200) {
      return {
        'tweets':             <dynamic>[],
        'next_remote_cursor': null,
        'next_db_cursor':     null,
      };
    }

    final body = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
    return {
      'tweets':             body['tweets'] as List<dynamic>,
      'next_remote_cursor': body['next_remote_cursor'] as String?,
      'next_db_cursor':     body['next_db_cursor']     as String?,
    };
  }
}