import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mediaproject/presentation/viewmodels/profile_viewmodel.dart';
import 'app_bar_drawer_tile.dart';

class AppBarDrawer extends StatefulWidget {
  const AppBarDrawer({Key? key}) : super(key: key);

  @override
  State<AppBarDrawer> createState() => _AppBarDrawerState();
}

class _AppBarDrawerState extends State<AppBarDrawer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadProfileIfNeeded();
    });
  }

  /// 필요한 경우에만 프로필 로드
  Future<void> _loadProfileIfNeeded() async {
    final authVm = context.read<AuthViewModel>();
    final profileVm = context.read<ProfileViewModel>();

    final currentTweetId = await authVm.fetchCurrentTweetId();

    if (currentTweetId != null && currentTweetId.isNotEmpty) {
      // 사용자가 변경되었거나 프로필이 로드되지 않은 경우에만 로드
      if (profileVm.isUserChanged(currentTweetId) || !profileVm.isProfileLoaded) {
        await profileVm.loadUserProfile(currentTweetId);
      }
    }
  }

  /// 로그아웃 처리
  Future<void> _logout(BuildContext context) async {
    final authVm = context.read<AuthViewModel>();
    final profileVm = context.read<ProfileViewModel>();

    await authVm.logout();
    profileVm.clearProfile(); // 프로필 초기화

    Navigator.of(context).pop();
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
              _buildProfileHeader(profileVm, colors),

              const SizedBox(height: 20),
              Divider(color: colors.secondary),
              const SizedBox(height: 10),

              // --- 메뉴 항목들 ---
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
                onTap: () => _navigateToProfile(context, profileVm),
              ),

              AppBarDrawerTile(
                title: "내 오시",
                icon: Icons.favorite_outline,
                textStyle: textStyle,
                iconColor: colors.primary,
                onTap: () {
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

  /// 프로필 헤더 빌드
  Widget _buildProfileHeader(ProfileViewModel profileVm, ColorScheme colors) {
    if (profileVm.isLoading) {
      return const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (profileVm.userProfile == null) {
      return const CircleAvatar(
        radius: 36,
        child: Icon(Icons.person, size: 36),
      );
    }

    final profile = profileVm.userProfile!;
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: profile.userProfileImageUrl != null
              ? NetworkImage(profile.userProfileImageUrl!.replaceAll('_normal', '_400x400'))
              : null,
          backgroundColor: Colors.grey[200],
          child: profile.userProfileImageUrl == null
              ? const Icon(Icons.person, size: 28)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '@${profile.tweetId}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 프로필 화면으로 이동
  void _navigateToProfile(BuildContext context, ProfileViewModel profileVm) {
    Navigator.of(context).pop();
    final tweetId = profileVm.userProfile?.tweetId;
    if (tweetId != null) {
      Navigator.of(context).pushNamed('/profile', arguments: tweetId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("프로필을 불러올 수 없습니다.")),
      );
    }
  }
}