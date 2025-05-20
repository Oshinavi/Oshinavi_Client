import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/components/bio_box.dart';
import 'package:mediaproject/services/oshi_service.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';

class OshiProfilePage extends StatefulWidget {
  const OshiProfilePage({super.key});
  static const routeName = '/oshi_profile';

  @override
  State<OshiProfilePage> createState() => _OshiProfilePageState();
}

class _OshiProfilePageState extends State<OshiProfilePage> {
  bool _isLoading = true;
  bool _initialized = false;
  Map<String, dynamic>? oshi;

  final TextEditingController _registerController = TextEditingController();
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<UserProfileProvider>().loadProfile()
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(_loadOshi);
    }
  }

  Future<void> _loadOshi() async {
    setState(() => _isLoading = true);
    final result = await OshiService().getOshi();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      oshi = result.containsKey('error') ? null : result;
    });
  }

  Future<void> _registerOshi() async {
    final inputId = _registerController.text.trim();
    if (inputId.isEmpty) return;

    setState(() => _isRegistering = true);
    final result = await OshiService().registerOshi(inputId);
    setState(() => _isRegistering = false);

    if (result.containsKey('error')) {
      // ← 반드시 await
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('오류'),
          content: Text(result['error']!),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
      return;
    }

    // 성공
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오시 등록에 성공했어요!'))
    );
    await _loadOshi();
  }

  Future<void> _changeOshi() async {
    final newId = await showDialog<String>(
      context: context,
      builder: (_) => _OshiChangeDialog(initial: oshi?['oshi_tweet_id'] ?? ''),
    );
    if (newId == null || newId.isEmpty) return;

    final result = await OshiService().registerOshi(newId);
    if (result.containsKey('error')) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('오류'),
          content: Text(result['error']!),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('오시가 변경되었습니다.')));
      await _loadOshi();
    }
  }

  Future<void> _deleteOshi() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('오시 삭제'),
        content: const Text('정말 등록된 오시를 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final success = await OshiService().deleteOshi();
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('오시가 삭제되었습니다.')));
      await _loadOshi();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('오시 삭제에 실패했습니다.')));
    }
  }

  String? _getHighResImage(String? url) =>
      url?.replaceAll('_normal', '_400x400');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 로딩 상태
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 오시가 등록되지 않은 경우
    final screenId = oshi?['oshi_tweet_id'] as String? ?? '';
    if (screenId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('오시 프로필')),
        body: Center(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('아직 등록된 오시가 없어요', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _registerController,
                    decoration: const InputDecoration(
                      labelText: '트위터 ID 입력',
                      hintText: '예: cocona_nonaka',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRegistering ? null : _registerOshi,
                      child: _isRegistering
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('오시 등록'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 오시가 등록된 경우
    return FutureBuilder<UserProfile?>(
      future: context.read<DatabaseProvider>().getUserProfile(screenId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snap.data!;
        final bannerUrl = user.userProfileBannerUrl;
        final avatarUrl = _getHighResImage(user.userProfileImageUrl);

        return Scaffold(
          appBar: AppBar(title: const Text('오시 프로필')),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 배너 + 프로필 사진
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 배너
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: bannerUrl != null
                          ? Image.network(bannerUrl, fit: BoxFit.cover, width: double.infinity)
                          : null,
                    ),
                    // 프로필 이미지
                    Positioned(
                      top: 150,
                      left: 16,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름 · 아이디
                      Text(
                        user.username,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.tweetId}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 12),

                      // 팔로우·변경·삭제 버튼
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: theme.colorScheme.onPrimary,
                              foregroundColor: theme.colorScheme.primary,
                            ),
                            child: const Text('팔로우 중'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _changeOshi,
                            style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                            child: const Text('변경'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _deleteOshi,
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              side: BorderSide(color: Colors.redAccent),
                            ),
                            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 팔로잉·팔로워 수 (예시)
                      Row(
                        children: [
                          Text('${user.followingCount} 팔로잉', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 16),
                          Text('${user.followersCount} 팔로워', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 소개
                      BioBox(text: user.bio),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 오시 변경 다이얼로그
class _OshiChangeDialog extends StatefulWidget {
  final String initial;
  const _OshiChangeDialog({required this.initial});

  @override
  State<_OshiChangeDialog> createState() => _OshiChangeDialogState();
}

class _OshiChangeDialogState extends State<_OshiChangeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('오시 변경'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: '트위터 ID',
          hintText: '예: cocona_nonaka',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        TextButton(onPressed: () => Navigator.pop(context, _controller.text.trim()), child: const Text('변경')),
      ],
    );
  }
}