import 'package:flutter/material.dart';

/*
INPUT ALERT BOX

유저가 타이핑 가능한 alert dialog box

To use this widget, you need:

- text controller (to access what the user type)
- hint text
- a fuction (e.g. PostMessage)
- text 4 button (e.g. "Save")

*/

class InputAlertBox extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final VoidCallback onPressed;
  final String onPressedText;

  const InputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText,
  });

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
            Navigator.pop(context);
            onPressed();
            textController.clear();
          },
          child: Text(onPressedText),
        ),
      ],
    );
  }
}