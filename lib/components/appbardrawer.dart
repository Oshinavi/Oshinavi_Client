import 'package:flutter/material.dart';
import 'package:mediaproject/components/appbardrawertile.dart';
import 'package:mediaproject/pages/oshi_profile_page.dart';
import 'package:mediaproject/pages/profile_page.dart';
import 'package:mediaproject/pages/settings_page.dart';
import 'package:mediaproject/services/auth/auth_service.dart';

import '../pages/login_page.dart';

class AppBarDrawer extends StatelessWidget {
  AppBarDrawer({super.key});

  //authservice에 접근
  final _auth = AuthService();

  // 로그아웃 처리
  void logout(BuildContext context) async {
    final result = await _auth.logout();  // 로그아웃을 비동기적으로 실행

    if (result.containsKey('error')) {
      // 로그아웃 실패 시 오류 메시지 출력
      print('Logout failed: ${result['error']}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('로그아웃 실패'),
            content: Text(result['error']),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // 로그아웃 성공 후 처리
      print('Logout successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onTap: () {})), // 로그인 페이지로 이동 (로그아웃 후)
      );
    }
  }

  //UI 생성
  @override
  Widget build(BuildContext context) {
    //Drawer
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              //어플 로고
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),

              const SizedBox(height: 10,),

              //홈 리스트 타이틀
              AppBarDrawerTile(
                title: "홈",
                icon: Icons.home,
                onTap: () {
                  // 드로어 닫고 홈으로 나가기
                  Navigator.pop(context);
                },
              ),

              //프로필 리스트 타이틀
              AppBarDrawerTile(
                title: "프로필",
                icon: Icons.person,
                  onTap: () async {
                    Navigator.pop(context); // 메뉴 닫기

                    String? tweetId = await _auth.getCurrentTweetid();

                    if (tweetId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(tweetId: tweetId),
                        ),
                      );
                    } else {
                      // tweetId가 없을 경우 예외 처리 (예: 에러 다이얼로그 띄우기)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("트윗 ID를 불러올 수 없습니다.")),
                      );
                    }
                  }
              ),

              AppBarDrawerTile(
                title: "내 오시",
                icon: Icons.settings,
                onTap: () {
                  Navigator.pop(context); // 일단 닫고

                  // ✅ 프레임이 끝난 후 push 실행
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OshiProfilePage()),
                    );
                  });
                },
              ),

              //서치 리스트 타이틀

              //세팅 리스트 타이틀
          AppBarDrawerTile(
            title: "설정",
            icon: Icons.settings,
            onTap: () {
              //일단 홈으로 나간 뒤 설정 페이지로 이동
              Navigator.pop(context);

              Navigator.push(context, MaterialPageRoute(
                builder: (context) => SettingsPage(),
                ),
              );
            },
          ),

              const Spacer(),

              //로그아웃
            AppBarDrawerTile(
              title: "로그아웃",
              icon: Icons.logout,
              onTap: () => logout(context),
            )
            ],
          ),
        )
      )
    );
  }
}