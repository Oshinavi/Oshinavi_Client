import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  void initState() {
    super.initState();
    // 마운트 직후에 프로필 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserProfileProvider>();

    // 로딩 중이면 스피너
    if (vm.isLoading) {
      return const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final UserProfile? profile = vm.profile;
    // 로드 실패나 로그아웃 상태면 기본 아바타
    if (profile == null) {
      return const CircleAvatar(
        radius: 36,
        child: Icon(Icons.person, size: 36),
      );
    }

    // 정상 로드된 프로필 표시
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: profile.userProfileImageUrl != null
              ? NetworkImage(profile.userProfileImageUrl!)
              : null,
          backgroundColor: Colors.grey[200],
          child: profile.userProfileImageUrl == null
              ? const Icon(Icons.person, size: 28, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.username,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('@${profile.tweetId}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ],
    );
  }
}