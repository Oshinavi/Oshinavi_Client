import 'package:flutter/material.dart';

/// InputAlertDialog:
/// - 텍스트 입력 필드와 확인/취소 버튼이 있는 AlertDialog
/// - 사용자가 입력한 텍스트를 onConfirm 콜백으로 전달하고 다이얼로그 닫음
/// 파라미터:
/// - textController: 입력된 텍스트를 제어할 TextEditingController
/// - hintText: 입력 필드의 힌트 텍스트
/// - onConfirm: 확인 버튼 누를 때 실행할 콜백
/// - confirmText: 확인 버튼 텍스트 (예: "등록", "확인" 등)
class InputAlertDialog extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final VoidCallback onConfirm;
  final String confirmText;

  const InputAlertDialog({
    Key? key,
    required this.textController,
    required this.hintText,
    required this.onConfirm,
    required this.confirmText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      backgroundColor: cs.surface,
      content: TextField(
        controller: textController,
        maxLength: 280,
        decoration: InputDecoration(
          filled: true,
          fillColor: cs.secondary,
          hintText: hintText,
          hintStyle: TextStyle(color: cs.onSecondary),
          counterStyle: TextStyle(color: cs.onSecondary),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.onSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: cs.onSecondary,
          ),
          onPressed: () {
            // 1) 취소 시 다이얼로그 닫고 입력 필드 초기화
            Navigator.pop(context);
            textController.clear();
          },
          child: const Text('취소'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: cs.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            // 2) 확인 시 onConfirm 호출 후 다이얼로그 닫고 입력 필드 초기화
            Navigator.pop(context);
            onConfirm();
            textController.clear();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}