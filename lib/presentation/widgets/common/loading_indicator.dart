import 'package:flutter/material.dart';

/// LoadingIndicator:
/// - Center에 CircularProgressIndicator만 감싼 간단한 위젯
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: CircularProgressIndicator(
        color: cs.primary,
      ),
    );
  }
}