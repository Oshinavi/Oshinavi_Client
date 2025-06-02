import 'package:flutter/material.dart';

/// showLoadingCircle:
/// - 전체 화면을 덮는 투명 배경의 AlertDialog를 띄워 로딩 인디케이터 표시
void showLoadingCircle(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Center(child: CircularProgressIndicator()),
    ),
  );
}

/// hideLoadingCircle:
/// - 현재 Navigator 스택에서 팝하여 로딩 다이얼로그를 닫음
void hideLoadingCircle(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}