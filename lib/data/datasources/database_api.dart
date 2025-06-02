import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/configs/api_config.dart';
import '../models/user_profile_model.dart';
import '../models/post_model.dart';

/// DB 및 외부 트위터 API 호출을 담당하는 클래스
/// - 사용자 프로필 조회
/// - 커서 기반 페이징 된 트윗 목록 조회
/// - 전체 트윗 목록 조회
class DatabaseApi {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// 외부 트위터 사용자 프로필 조회
  /// GET /users/profile?tweet_id=<screenName>
  /// - JWT 토큰이 있을 경우 Authorization 헤더에 포함하여 호출
  /// - 성공 시 UserProfileModel 반환, 실패 시 null
  Future<UserProfileModel?> fetchUserProfile(String tweetId) async {
    final token = await _storage.read(key: 'jwt_token');
    final uri = Uri.parse(
        '${ApiConfig.host}${ApiConfig.apiBase}/users/profile?tweet_id=$tweetId');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes))
      as Map<String, dynamic>;
      return UserProfileModel.fromMap(data);
    }
    return null;
  }

  /// 커서(cursor) 기반 페이징 된 트윗 목록 조회
  /// GET /tweets/<screenName>?count=<int>&remote_cursor=<cursor>&db_cursor=<cursor>
  /// - 성공 시 Map { 'tweets': List<dynamic>, 'next_remote_cursor': String?, 'next_db_cursor': String? }
  /// - 실패 시 빈 리스트와 null 커서를 가진 Map 반환
  Future<Map<String, dynamic>> fetchPostPage({
    required String screenName,
    String? remoteCursor,
    String? dbCursor,
    int count = 20,
  }) async {
    final token = await _storage.read(key: 'jwt_token');
    var uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/tweets/$screenName');

    // 쿼리 파라미터 설정
    final qp = <String, String>{'count': '$count'};
    if (remoteCursor != null) qp['remote_cursor'] = remoteCursor;
    if (dbCursor != null) qp['db_cursor'] = dbCursor;
    uri = uri.replace(queryParameters: qp);

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) {
      return {
        'tweets': <dynamic>[],
        'next_remote_cursor': null,
        'next_db_cursor': null,
      };
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return {
      'tweets': body['tweets'] as List<dynamic>,
      'next_remote_cursor': body['next_remote_cursor'] as String?,
      'next_db_cursor': body['next_db_cursor'] as String?,
    };
  }

  /// 모든 트윗 목록을 한 번에 조회
  /// GET /tweets/<screenName> (cursor 없이)
  /// - 성공 시 List<PostModel>, 실패 시 빈 리스트
  Future<List<PostModel>> fetchAllPosts(String screenName) async {
    final token = await _storage.read(key: 'jwt_token');
    final uri = Uri.parse('${ApiConfig.host}${ApiConfig.apiBase}/tweets/$screenName');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);
    if (response.statusCode != 200) return [];

    try {
      final List<dynamic> jsonList =
      jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return jsonList
          .map((e) => PostModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}