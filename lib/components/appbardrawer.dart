import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/components/appbardrawertile.dart';
import 'package:mediaproject/components/profile_header.dart';
import 'package:mediaproject/pages/oshi_profile_page.dart';
import 'package:mediaproject/pages/profile_page.dart';
import 'package:mediaproject/pages/settings_page.dart';
import 'package:mediaproject/pages/monthly_calendar_page.dart';
import 'package:mediaproject/services/auth/login_or_register.dart';
import 'package:mediaproject/services/auth/auth_service.dart';
import 'package:mediaproject/main.dart';

import '../providers/user_profile_provider.dart';

class AppBarDrawer extends StatefulWidget {
  AppBarDrawer({Key? key}) : super(key: key);

  @override
  State<AppBarDrawer> createState() => _AppBarDrawerState();
}

class _AppBarDrawerState extends State<AppBarDrawer> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    // ① 드로어 최초 생성 시 프로필 한 번 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadProfile();
    });
  }

  Future<void> _logout(BuildContext context) async {
    // 1) 로컬 토큰 정리
    await _auth.logout();

    // ② 로그아웃 시 프로필 클리어
    context.read<UserProfileProvider>().clearProfile();

    // 2) 드로어 닫기
    Navigator.of(context).pop();

    // 3) 루트 스택 초기화 → 로그인 화면으로
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState!
          .pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginOrRegister()),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors    = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleMedium!;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 프로필 헤더 컴포넌트 (reads from provider)
              const ProfileHeader(),

              const SizedBox(height: 20),
              Divider(color: colors.secondary),
              const SizedBox(height: 10),

              AppBarDrawerTile(
                title: "홈",
                icon: Icons.home,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () => Navigator.of(context).pop(),
              ),

              AppBarDrawerTile(
                title: "프로필",
                icon: Icons.person,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () async {
                  Navigator.of(context).pop();
                  final tweetId = await _auth.getCurrentTweetId();
                  if (tweetId != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      navigatorKey.currentState!.push(
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(tweetId: tweetId),
                        ),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("트윗 ID를 불러올 수 없습니다.")),
                    );
                  }
                },
              ),

              AppBarDrawerTile(
                title: "내 오시",
                icon: Icons.favorite_outline,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (_) => const OshiProfilePage()),
                    );
                  });
                },
              ),

              AppBarDrawerTile(
                title: "캘린더",
                icon: Icons.calendar_today,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (_) => const MonthlyCalendarPage()),
                    );
                  });
                },
              ),

              AppBarDrawerTile(
                title: "설정",
                icon: Icons.settings,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () {
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    navigatorKey.currentState!.push(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  });
                },
              ),

              const Spacer(),

              AppBarDrawerTile(
                title: "로그아웃",
                icon: Icons.logout,
                textStyle: textStyle,
                iconColor: colors.error,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}