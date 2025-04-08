import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediaproject/pages/home_page.dart';
import 'package:mediaproject/services/auth/login_or_register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // JWT 토큰을 secure storage에서 가져오는 함수
  Future<String?> getToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'jwt_token');  // 'jwt_token'으로 저장된 토큰을 가져옴
  }

  // 로그인 상태를 확인하는 함수 (서버에 요청을 보내서 로그인 여부를 확인)
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();  // 저장된 JWT 토큰 가져오기

      if (token == null) {
        return false;  // 토큰이 없다면 로그인되지 않음
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/api/check_login'),  // Flask 서버에 로그인 상태 확인 요청
        headers: {
          'Authorization': 'Bearer $token',  // JWT 토큰을 헤더에 포함
        },
      );

      if (response.statusCode == 200) {
        // 로그인 상태 확인 성공 (응답이 200이면 로그인됨)
        return true;
      } else {
        // 로그인 상태가 아님
        return false;
      }
    } catch (e) {
      // 오류 처리 (네트워크 오류 등)
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),  // 로그인 여부를 비동기적으로 체크
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 서버 응답을 기다리는 동안 로딩 화면을 표시
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // 에러 발생 시 오류 메시지 표시
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == true) {
          // 로그인 되어 있으면 홈 화면으로 이동
          return const HomePage();  // 홈 화면 (사용자가 로그인되어 있을 경우)
        } else {
          // 로그인 안 되어 있으면 로그인 페이지로 이동
          return const LoginOrRegister();  // 로그인 화면 (사용자가 로그인되지 않았을 경우)
        }
      },
    );
  }
}