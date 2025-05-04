import 'package:flutter/material.dart';

/// 일정 추가용 FAB 컴포넌트
class AddScheduleFab extends StatelessWidget {
  /// 버튼 클릭 시 호출될 콜백
  final VoidCallback onPressed;

  const AddScheduleFab({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: '새 일정 추가',
      child: const Icon(Icons.add),
    );
  }
}