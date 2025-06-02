import 'package:flutter/material.dart';

/// SettingsTile:
/// - 설정 화면에서 제목과 우측에 액션(Widget)을 나란히 표시하는 커스텀 타일
/// 사용법:
/// - title: 타일 왼쪽에 표시할 텍스트
/// - action: 우측에 표시할 위젯(예: Switch, IconButton 등)
class SettingsTile extends StatelessWidget {
  final String title;
  final Widget action;

  const SettingsTile({
    super.key,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: cs.onSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          action, // 설정 화면에서 제공할 액션 위젯 (Switch 등)
        ],
      ),
    );
  }
}