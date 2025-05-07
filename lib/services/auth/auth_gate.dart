import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mediaproject/pages/home_page.dart';
import 'package:mediaproject/services/auth/login_or_register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> getToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/auth/check_login'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == true) {
          return const HomePage();
        } else {
          return const LoginOrRegister();
        }
      },
    );
  }
}