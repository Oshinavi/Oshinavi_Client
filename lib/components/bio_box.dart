import 'package:flutter/material.dart';

/*
User BIO Section - Twitter 스타일 텍스트 중심 구성
*/

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 바이오 텍스트 (타이틀 없이 바로 시작)
          Text(
            text.isNotEmpty ? text : "바이오 정보가 없습니다.",
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}