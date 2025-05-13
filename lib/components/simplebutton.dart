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
  final VoidCallback? onTap;

  const SimpleButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: const StadiumBorder(),
          elevation: 2,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(text),
      ),
    );
  }
}