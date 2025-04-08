import 'package:flutter/material.dart';
import 'package:mediaproject/pages/login_page.dart';
import 'package:mediaproject/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // 초기엔 로그인 페이지 보여주기
  bool showLoginPage = true;

  // 로그인/등록 페이지 토글
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    }
    else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}
