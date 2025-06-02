import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mediaproject/presentation/viewmodels/profile_viewmodel.dart';
import 'app_bar_drawer_tile.dart';

/// AppBarDrawer:
/// - 앱의 왼쪽 드로어에 사용자 프로필과 네비게이션 메뉴 항목을 표시
/// - AuthViewModel을 통해 현재 로그인된 사용자의 tweetId를 가져와 ProfileViewModel에 전달
/// - 메뉴 선택 시 해당 화면으로 이동하거나 로그아웃 처리
class AppBarDrawer extends StatefulWidget {
  const AppBarDrawer({Key? key}) : super(key: key);

  @override
  State<AppBarDrawer> createState() => _AppBarDrawerState();
}

class _AppBarDrawerState extends State<AppBarDrawer> {
  @override
  void initState() {
    super.initState();
    // 1) 위젯 생성 후 첫 프레임 렌더링이 끝난 시점에 콜백 실행
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 2) AuthViewModel.fetchCurrentTweetId()로 현재 로그인된 사용자의 tweetId 조회
      final tweetId = await context.read<AuthViewModel>().fetchCurrentTweetId();
      // 3) tweetId가 null이면 빈 문자열("")을, 아니면 실제 tweetId 값을 전달하여
      //    ProfileViewModel.loadUserProfile() 호출
      context.read<ProfileViewModel>().loadUserProfile(tweetId ?? '');
    });
  }

  /// _logout:
  /// - AuthViewModel.logout() 호출하여 서버 세션/토큰 무효화
  /// - ProfileViewModel.userProfile을 null로 초기화
  /// - 드로어 닫은 뒤 '/auth_gate' 경로로 네비게이션 (로그인 화면으로 복귀)
  Future<void> _logout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    context.read<ProfileViewModel>().userProfile = null;
    Navigator.of(context).pop(); // 드로어 닫기
    Future.microtask(() {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/auth_gate',
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.titleMedium!;
    final profileVm = context.watch<ProfileViewModel>();

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- 프로필 헤더 ---
              if (profileVm.isLoading)
              // 1) ProfileViewModel.isLoading이 true인 경우 로딩 인디케이터 표시
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (profileVm.userProfile == null)
              // 2) userProfile이 null인 경우 기본 아바타 표시
                const CircleAvatar(
                  radius: 36,
                  child: Icon(Icons.person, size: 36),
                )
              else
              // 3) userProfile이 존재하면 프로필 이미지를 로드하고 텍스트 표시
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        profileVm.userProfile!.userProfileImageUrl!
                            .replaceAll('_normal', '_400x400'),
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileVm.userProfile!.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${profileVm.userProfile!.tweetId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 20),
              Divider(color: colors.secondary),
              const SizedBox(height: 10),

              // --- 메뉴 항목들 ---
              AppBarDrawerTile(
                title: "홈",
                icon: Icons.home,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () {
                  // 4) 홈 메뉴 선택 시 드로어만 닫음 (HomePage는 이미 보여지고 있음)
                  Navigator.of(context).pop();
                },
              ),

              AppBarDrawerTile(
                title: "프로필",
                icon: Icons.person,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () {
                  // 5) 프로필 메뉴 선택 시 드로어 닫고 '/profile' 화면으로 이동
                  Navigator.of(context).pop();
                  final tweetId = profileVm.userProfile?.tweetId;
                  if (tweetId != null) {
                    Navigator.of(context).pushNamed(
                      '/profile',
                      arguments: tweetId,
                    );
                  } else {
                    // 프로필 로드 실패 시 스낵바로 안내
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
                  // 6) 오시 관리 화면으로 이동
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/oshi_profile');
                },
              ),

              AppBarDrawerTile(
                title: "캘린더",
                icon: Icons.calendar_today,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () {
                  // 7) 달력 화면으로 이동
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/monthly_calendar');
                },
              ),

              AppBarDrawerTile(
                title: "설정",
                icon: Icons.settings,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () {
                  // 8) 설정 화면으로 이동
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/settings');
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