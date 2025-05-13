import 'package:flutter/material.dart';

/*

로그인 화면용 텍스트필드

사용을 위해
- textController()
- hintText()
- obscureText()
위 셋을 반드시 정의할 것.

*/

class TextFieldLogin extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const TextFieldLogin({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

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
          hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          filled: true,
          fillColor: cs.surface,            // 배경은 surface
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32.0),
            borderSide: BorderSide(color: cs.onSurface.withOpacity(0.2), width: 1),
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