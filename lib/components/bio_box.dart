import 'package:flutter/material.dart';

/*
User BIO Section - Twitter 스타일 텍스트 중심 구성
*/

class BioBox extends StatelessWidget {
  final String? text;            // ✅ nullable 로 변경

  const BioBox({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // null 이거나 빈 문자열이면 기본 메시지 표시
    final displayText =
    (text != null && text!.trim().isNotEmpty) ? text! : '바이오 정보가 없습니다.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}