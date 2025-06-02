import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

/// LoginOrRegisterToggle:
/// - 로그인 화면(LoginPage)과 회원가입 화면(RegisterPage)을 토글하여 보여주는 위젯
/// - _showLogin 플래그에 따라 해당 위젯을 반환하며 토글 시 setState로 화면 전환
/// 주요 단계:
/// 1) 초기 _showLogin = true → LoginPage 표시
/// 2) LoginPage 또는 RegisterPage에서 _toggle() 호출 시 화면 전환
class LoginOrRegisterToggle extends StatefulWidget {
  const LoginOrRegisterToggle({Key? key}) : super(key: key);

  @override
  _LoginOrRegisterToggleState createState() => _LoginOrRegisterToggleState();
}

class _LoginOrRegisterToggleState extends State<LoginOrRegisterToggle> {
  bool _showLogin = true;  // true이면 로그인 화면, false이면 회원가입 화면

  /// _toggle:
  /// - _showLogin 플래그를 반전시켜 로그인/회원가입 화면 전환
  void _toggle() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1) _showLogin 플래그에 따라 LoginPage 또는 RegisterPage 반환
    return _showLogin
        ? LoginPage(toggleToRegister: _toggle)  // 로그인 화면
        : RegisterPage(onTap: _toggle);          // 회원가입 화면
  }
}