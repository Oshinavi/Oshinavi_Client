import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/presentation/widgets/common/bio_box.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../../domain/entities/user_profile.dart';

/// ProfilePage:
/// - 특정 트위터 ID(@tweetId)에 해당하는 사용자 프로필 정보를 로드하여 표시
/// 주요 단계:
/// 1) initState에서 ProfileViewModel.loadUserProfile 호출
/// 2) vm.isLoading true인 동안 로딩 인디케이터 표시
/// 3) vm.errorMessage가 있거나 userProfile이 null인 경우 에러 UI 표시
/// 4) 정상적으로 userProfile 로드되면 배너, 프로필 사진, 이름, 스크린네임, 팔로잉·팔로워 수, 바이오 표시
class ProfilePage extends StatefulWidget {
  final String tweetId;
  const ProfilePage({Key? key, required this.tweetId}) : super(key: key);
  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // 1) 빌드 후 한 번만 호출: 사용자 프로필 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserProfile(widget.tweetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<ProfileViewModel>();

    // 2) 로딩 중일 때 로딩 인디케이터
    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3) 에러 발생 시 에러 메시지 표시
    if (vm.errorMessage != null || vm.userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("유저 정보")),
        body: Center(
          child: Text(vm.errorMessage ?? '유저 정보를 불러오는 데 실패했습니다.'),
        ),
      );
    }

    // 4) 사용자 프로필이 정상 로드되었을 때
    final UserProfile user = vm.userProfile!;
    final profileImageUrl =
    user.userProfileImageUrl?.replaceAll('_normal', '_400x400');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          user.username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        foregroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배너 + 프로필 이미지
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 배너: 없으면 빈 컨테이너 (회색 배경)
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: user.userProfileBannerUrl != null
                      ? Image.network(
                    user.userProfileBannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  )
                      : Container(color: theme.colorScheme.surfaceContainerHighest),
                ),
                // 프로필 이미지
                Positioned(
                  bottom: -48,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null
                          ? Icon(
                        Icons.person,
                        size: 48,
                        color: theme.colorScheme.primary,
                      )
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // 사용자 정보 블록: 이름, 스크린네임, 팔로잉·팔로워, 바이오
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // 이름
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 스크린네임 (@tweetId)
                  Text(
                    '@${user.tweetId}',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 팔로잉·팔로워 수
                  Row(
                    children: [
                      Text(
                        '${user.followingCount} 팔로잉',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${user.followersCount} 팔로워',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // 바이오: BioBox 위젯으로 표시
                  if (user.bio != null && user.bio!.trim().isNotEmpty)
                    BioBox(text: user.bio!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}