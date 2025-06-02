import 'package:flutter/material.dart';

/// BioBox:
/// - 사용자 프로필의 바이오를 표시하는 위젯
/// - 바이오 텍스트가 null이거나 빈 문자열인 경우 기본 안내 텍스트 표시
/// 파라미터:
/// - text: 표시할 바이오 텍스트 (선택값)
class BioBox extends StatelessWidget {
  final String? text;

  const BioBox({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = (text != null && text!.trim().isNotEmpty)
        ? text!
        : '바이오 정보가 없습니다.';

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