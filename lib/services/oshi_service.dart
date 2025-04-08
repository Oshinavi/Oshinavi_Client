import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mediaproject/models/user.dart';

class OshiService {
  final String baseUrl = 'http://127.0.0.1:5000';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getOshi() async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        return {'error': "로그인이 필요합니다."};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/user/oshi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'oshi_tweet_id': responseData['oshi_tweet_id'],
          'oshi_username': responseData['oshi_username']
        };
      } else {
        return {
          'error': responseData['error'] ?? "오시 정보를 불러오는 데 실패했습니다."
        };
      }
    } catch (e) {
      return {'error': "오류가 발생했습니다: $e"};
    }
  }

  // 오시 등록 요청
  Future<Map<String, dynamic>> registerOshi(String oshiTweetId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');

      if (token == null) {
        return {'error': "로그인이 필요합니다."};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/user/oshi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'oshi_tweet_id': oshiTweetId}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'message': responseData['message']};
      } else if (response.statusCode == 400 &&
          responseData['error'] == 'No such user exists') {
        return {'error': "존재하지 않는 유저입니다."};
      } else {
        return {'error': responseData['error'] ?? "요청에 문제가 발생했습니다."};
      }
    } catch (e) {
      return {'error': "오류가 발생했습니다: $e"};
    }
  }

  Future<UserProfile?> getUserProfile(String tweetId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user?tweet_id=$tweetId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return UserProfile.fromMap(responseData);
      } else {
        print('⚠️ 서버 응답 오류: ${responseData['error']}');
        return null;
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      return null;
    }
  }
}