import 'package:flutter/material.dart';
import 'package:mediaproject/components/bio_box.dart';
import 'package:mediaproject/models/user.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String tweetId;
  const ProfilePage({super.key, required this.tweetId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

  UserProfile? user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.getUserProfile(widget.tweetId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator()
          )
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("유저 정보")),
        body: const Center(child: Text("유저 정보를 불러오는 데 실패했습니다.")),
      );
    }

    final profileImageUrl = user!.userProfileImageUrl?.replaceAll('_normal', '_400x400');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          user!.username,
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
            // 배너와 프로필 이미지
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 배너
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: user!.userProfileBannerUrl != null
                      ? Image.network(
                    user!.userProfileBannerUrl!,
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
                      backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                      child: profileImageUrl == null
                          ? Icon(Icons.person, size: 48, color: theme.colorScheme.primary)
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // 유저 정보 블록
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // 이름
                  Text(
                    user!.username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // 스크린네임
                  Text(
                    '@${user!.tweetId}',
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 바이오
                  if (user!.bio != null && user!.bio!.isNotEmpty)
                    BioBox(text: user!.bio!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}