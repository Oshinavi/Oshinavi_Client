import 'package:flutter/material.dart';

/// SimpleButton:
/// - Full-width 스타일의 둥근 버튼
/// - enabled 플래그로 활성화/비활성화 제어
/// 파라미터:
/// - text: 버튼에 표시할 텍스트
/// - onTap: 버튼 클릭 시 실행할 콜백
/// - enabled: 버튼 활성화 여부 (기본값: true)
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
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: enabled ? onTap : null,
        child: Text(text),
      ),
    );
  }
}