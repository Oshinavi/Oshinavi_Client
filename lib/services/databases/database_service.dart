import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mediaproject/models/user.dart';
import 'package:mediaproject/models/post.dart';

class DatabaseService {
  // Android 에뮬레이터 ↔ PC 로컬 호스트 매핑
  final String _baseHost = Platform.isAndroid
      ? 'http://10.0.2.2:5000'
      : 'http://127.0.0.1:5000';
  static const _api = '/api';

  /// (1) 회원가입/유저 정보 저장 → 기존 '/api/users/save' 대신 '/api/signup' 호출
  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String cfpassword,
    required String tweetId,
  }) async {
    final uri = Uri.parse('$_baseHost$_api/signup');
    final body = json.encode({
      'username': username,
      'email': email,
      'password': password,
      'cfpassword': cfpassword,
      'tweetId': tweetId,
    });

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return resp.statusCode == 201;
  }

  /// (2) 유저 프로필 조회
  Future<UserProfile?> getUserFromDB(String tweetId) async {
    final uri = Uri.parse('$_baseHost$_api/users?tweet_id=$tweetId');
    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (resp.statusCode != 200) return null;
    try {
      final data = json.decode(resp.body);
      return UserProfile.fromMap(data);
    } catch (_) {
      // JSON 형식이 아니면 null
      return null;
    }
  }

  /// (3) 스크린네임으로 트윗 목록 가져오기
  Future<List<Post>> getAllPostFromDB(String screenName) async {
    final uri = Uri.parse('$_baseHost$_api/tweets/$screenName');

    http.Response resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    // 500 에러 시 재시도
    if (resp.statusCode == 500) {
      await Future.delayed(const Duration(milliseconds: 300));
      resp = await http.get(uri, headers: {
        'Content-Type': 'application/json',
      });
    }

    if (resp.statusCode != 200) return [];

    try {
      final List<dynamic> jsonList = json.decode(resp.body);
      return jsonList.map((e) => Post.fromMap(e)).toList();
    } catch (e) {
      // 파싱 실패
      print('❌ JSON 파싱 오류(getAllPost): $e');
      return [];
    }
  }
}