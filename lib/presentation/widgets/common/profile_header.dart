import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../../domain/entities/user_profile.dart';

/// ProfileHeader:
/// - 사용자 프로필 화면 상단에 사용자 아바타와 이름 스크린네임을 표시
/// - AuthViewModel.fetchCurrentTweetId()로 현재 로그인된 사용자의 tweetId를 가져와 ProfileViewModel.loadUserProfile() 호출

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final UserProfile? profile = vm.userProfile;

    if (vm.isLoading) {
      return const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (profile == null) {
      return const CircleAvatar(
        radius: 36,
        child: Icon(Icons.person, size: 36),
      );
    }

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
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}