import 'package:flutter/material.dart';

/// TextFieldLogin:
/// - 로그인/회원가입 화면에서 사용하는 스타일링된 TextField
/// 파라미터:
/// - controller: 입력 값을 제어할 TextEditingController
/// - hintText: 힌트 텍스트
/// - obscureText: 비밀번호 입력 등 가림 여부
class TextFieldLogin extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const TextFieldLogin({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: cs.onSurface),
        cursorColor: cs.primary,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: cs.onSurface.withAlpha(128)),
          filled: true,
          fillColor: cs.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: cs.onSurface.withAlpha(51), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
        ),
      ),
    );
  }
}