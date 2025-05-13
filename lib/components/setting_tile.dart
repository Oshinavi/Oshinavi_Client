import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*

드로어 타일

사용을 위해
- title()
- action()
위 둘을 반드시 정의할 것.

*/

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
          action,
        ],
      ),
    );
  }
}