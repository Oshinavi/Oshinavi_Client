import 'package:flutter/material.dart';

/// 화면 하단 또는 중간에 배치 가능한 커스텀 버튼
/// - text: 버튼에 표시할 텍스트
/// - onTap: 터치 시 콜백
///
/// 사용 예시:
/// ```
/// SimpleButton(
///   text: "로그인",
///   onTap: _login,
/// );
/// ```
class SimpleButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool enabled;

  const SimpleButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: enabled ? onTap : null,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}