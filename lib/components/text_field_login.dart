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
    required this. obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        //선택되지 않았을 때의 border

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        //선택되었을 때의 border
        focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
    borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
