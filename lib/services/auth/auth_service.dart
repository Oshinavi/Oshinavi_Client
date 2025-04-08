import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:5000';

  // JWT 토큰 저장용 변수
  String? _token;

  // 로그인 함수
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _token = responseData['token']; // 토큰 저장
        // SecureStorage에 토큰 저장
        final storage = FlutterSecureStorage();
        await storage.write(key: 'jwt_token', value: _token);
        print("Token received: $_token"); // 디버그용 출력
        return responseData;
      } else {
        return {'error': '아이디 또는 비밀번호가 일치하지 않습니다.'};
      }
    } catch (e) {
      return {'error': '네트워크 에러: ${e.toString()}'};
    }
  }

  // 회원가입 함수
  Future<Map<String, dynamic>> signup(String username, String email,
      String password, String cfpassword, String tweetId) async {
    final url = Uri.parse('$baseUrl/api/signup');

    if (password != cfpassword) {
      return {'error': '입력한 비밀번호가 일치하지 않습니다.'};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'cfpassword': cfpassword,
          'tweetId': tweetId,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final responseBody = json.decode(response.body);
        return {'error': responseBody['error']};
      }
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  // 로그아웃 함수
  Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse('$baseUrl/api/logout');

    if (_token == null) {
      final storage = FlutterSecureStorage();
      _token = await storage.read(key: 'jwt_token');
    }

    if (_token == null) {
      return {'error': '로그인된 사용자가 아닙니다.'};
    }

    print('Sending logout request to: $url');
    print('Authorization: Bearer $_token');

    final storage = FlutterSecureStorage();
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // regardless of success/failure, delete token
      _token = null;
      await storage.delete(key: 'jwt_token');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // 만료된 토큰이거나 인증 실패 → 그래도 로그아웃 처리
        return {'message': '이미 세션이 만료되었습니다. 로그아웃 처리되었습니다.'};
      } else {
        return {'error': '로그아웃 실패 (${response.statusCode})'};
      }
    } catch (e) {
      print('Error: ${e.toString()}');

      // 네트워크 오류에도 토큰 제거
      _token = null;
      await storage.delete(key: 'jwt_token');

      return {'error': '네트워크 오류: ${e.toString()}'};
    }
  }

  Future<String?> getCurrentTweetid() async{
    final url = Uri.parse('$baseUrl/api/user/tweet_id');

    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');

    if (token == null) {
      print("JWT 토큰이 없습니다.");
      return null;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      print("응답 본문: ${response.body}");
      print("응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        return data['tweetId'];
      } else {
        print("오류: ${data['error']}");
        return null;
      }
    } catch (e) {
      print("네트워크 오류: $e");
      return null;
    }
  }
}