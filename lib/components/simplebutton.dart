import 'package:flutter/material.dart';

/*

일반 버튼

사용을 위해
- text
- function()
위 둘을 반드시 정의할 것.

*/

class SimpleButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const SimpleButton({
    super.key,
    required this.text,
  required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          //버튼 색
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
            child: Text(text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      )
    );
  }
}
