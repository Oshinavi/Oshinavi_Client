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
    //컨테이너
    return Container(
      decoration: BoxDecoration(
        //색상
        color: Theme.of(context).colorScheme.secondary,
        //모서리 처리
        borderRadius: BorderRadius.circular(12),
      ),
      //패딩처리
      margin: const EdgeInsets.only(left: 25, right: 25, top: 10),
      padding: const EdgeInsets.all(25),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //타이틀
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          //액션
          action,
        ],
      ),
    );
  }
}
