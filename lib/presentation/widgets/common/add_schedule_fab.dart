import 'package:flutter/material.dart';

/// AddScheduleFab:
/// - 새 일정을 추가하는 FloatingActionButton 위젯
/// 파라미터:
/// - onPressed: 버튼이 눌렸을 때 실행할 콜백
class AddScheduleFab extends StatelessWidget {
  final VoidCallback onPressed;

  const AddScheduleFab({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: '새 일정 추가',
      child: const Icon(Icons.add),
    );
  }
}