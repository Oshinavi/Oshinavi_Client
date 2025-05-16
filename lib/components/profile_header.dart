import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserProfileProvider>();

    if (vm.isLoading) {
      return const SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final UserProfile? profile = vm.profile;
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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