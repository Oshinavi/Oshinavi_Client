import 'package:flutter/material.dart';

/// AppBarDrawerTile:
/// - AppBarDrawer 내부에서 사용되는 메뉴 항목용 ListTile
/// - 제목, 아이콘, 텍스트 스타일, 아이콘 색상, 탭 콜백 등을 인자로 받아 렌더링
/// 파라미터:
/// - title: 메뉴 타이틀 텍스트
/// - icon: 메뉴 아이콘
/// - onTap: 메뉴 클릭 시 실행할 콜백
/// - textStyle: 제목 텍스트 스타일 (선택값)
/// - iconColor: 아이콘 색상 (선택값)
class AppBarDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final TextStyle? textStyle;
  final Color? iconColor;

  const AppBarDrawerTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.textStyle,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? cs.primary),
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