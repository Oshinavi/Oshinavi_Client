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
    // 1) 위젯 렌더링 후 첫 프레임에서 비동기로 로그인된 tweetId 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tweetId = await context.read<AuthViewModel>().fetchCurrentTweetId();
      if (tweetId != null && tweetId.isNotEmpty) {
        // 2) tweetId가 유효하면 ProfileViewModel.loadUserProfile 호출
        context.read<ProfileViewModel>().loadUserProfile(tweetId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final UserProfile? profile = vm.userProfile;

    if (vm.isLoading) {
      // 3) 로딩 중일 때 로딩 인디케이터 표시
      return const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (profile == null) {
      // 4) 프로필이 null일 때 기본 아바타 표시
      return const CircleAvatar(
        radius: 36,
        child: Icon(Icons.person, size: 36),
      );
    }

    // 5) 프로필이 로드된 경우: CircleAvatar와 텍스트 표시
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
            Text(
              '@${profile.tweetId}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}