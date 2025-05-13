import 'package:flutter/material.dart';

//로딩 서클 출력
void showLoadingCircle(BuildContext context){
  showDialog(context: context,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(child: CircularProgressIndicator(),
        ),
      ),
  );
}

//로딩 서클 숨기기
void hideLoadingCircle(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}