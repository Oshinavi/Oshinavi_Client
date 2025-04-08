import 'package:flutter/material.dart';

/*

드로어 타일

사용을 위해
- title()
- icon()
- function()
위 셋을 반드시 정의할 것.

*/

class AppBarDrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function()? onTap;

  const AppBarDrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
});

  //UI 빌드
  @override
  Widget build(BuildContext context) {
    //List Tile
    return ListTile(
      title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,),
      onTap: onTap,
    );
  }
}
