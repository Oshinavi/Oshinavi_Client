import 'package:flutter/material.dart';

/// Drawer 에서 쓰이는 메뉴 아이템 위젯.
/// 기본으로는 Theme.of(context).colorScheme 을 사용하고,
/// 필요하면 호출부에서 스타일을 override 할 수 있도록 확장
class AppBarDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  /// 선택적 스타일링 파라미터
  final TextStyle? textStyle;
  final Color? iconColor;

  const AppBarDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.textStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? cs.primary,
      ),
      title: Text(
        title,
        style: textStyle ??
            TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}