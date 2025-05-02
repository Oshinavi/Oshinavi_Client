/*

트윗 정보 관련 기능

- 유저 프로필
- 메시지 포스팅
- 좋아요
- 리플
- 계정정보
- 팔로 및 언팔
- 유저 검색

*/

import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  // Base URL of your Flask server
  final String baseUrl = 'http://127.0.0.1:5000'; // Flask API URL

  //유저 정보 저장
  Future<void> saveUserInfo({
    required String tweetId,
    required String username,
  }) async {
    // Create a user profile object
    final Map<String, dynamic> user = {
      'tweet_id': tweetId,
      'username': username,
    };

    // Send a POST request to save user info
    final response = await http.post(
      Uri.parse('$baseUrl/api/user/save'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );

    if (response.statusCode == 200) {
      print('User information saved successfully');
    } else {
      print('Failed to save user information');
    }
  }

  // 백엔드에서 유저 정보 불러오기
  Future<UserProfile?> getUserFromDB(String tweetId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user?tweet_id=$tweetId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromMap(data);
    } else {
      print('Failed to fetch user data');
      return null;
    }
  }

  //메시지 포스트

  //DB로부터 모든 포스트 가져오기
  Future<List<Post>> getAllPostFromDB(String screenName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tweets/$screenName'),
        headers: {'Content-Type': 'application/json'},
      );

      // 첫 번째 시도 실패 && 500에러일 경우 한 번 더 재시도
      if (response.statusCode == 500) {
        print('🔁 백엔드 500에러, 재시도 중...');
        await Future.delayed(const Duration(milliseconds: 500)); // 잠깐 대기 후 재시도
        final retryResponse = await http.get(
          Uri.parse('$baseUrl/api/tweets/$screenName'),
          headers: {'Content-Type': 'application/json'},
        );

        if (retryResponse.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(retryResponse.body);
          return jsonList.map((item) => Post.fromMap(item)).toList();
        } else {
          print('🛑 재시도 후에도 실패: ${retryResponse.statusCode}');
          return [];
        }
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((item) => Post.fromMap(item)).toList();
      } else {
        print('Failed to fetch posts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching posts: $e');
      return [];
    }
  }

  //개별 포스트
}