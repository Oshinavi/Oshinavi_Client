import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/components/bio_box.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/oshi_service.dart';

import '../providers/user_profile_provider.dart';

class OshiProfilePage extends StatefulWidget {
  const OshiProfilePage({super.key});
  static const routeName = '/oshi_profile';

  @override
  State<OshiProfilePage> createState() => _OshiProfilePageState();
}

class _OshiProfilePageState extends State<OshiProfilePage> {
  @override
  void initState() {
    super.initState();
    // 로그인 직후 또는 didChangeDependencies에서 프로필 로드
    Future.microtask(() =>
        context.read<UserProfileProvider>().loadProfile()
    );
  }
  Map<String, dynamic>? oshi;
  bool _isLoading = true;
  bool _initialized = false;

  final TextEditingController _registerController = TextEditingController();
  bool _isRegistering = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(loadOshi);
    }
  }

  Future<void> loadOshi() async {
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
    if (!mounted) return;
    setState(() => _isRegistering = false);

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error']!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오시 등록에 성공했어요!')),
      );
      await loadOshi();
    }
  }

  String? getHighResImage(String? url) => url?.replaceAll('_normal', '_400x400');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenId = oshi?['oshi_tweet_id'] ?? '';
    final screenName = screenId.toString();

    if (screenName.isEmpty) {
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
                      hintText: '예: my_favorite_id',
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
                              color: Colors.white
                          )
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

    return FutureBuilder(
      future: Provider.of<DatabaseProvider>(context, listen: false).getUserProfile(screenName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('오시 프로필')),
            body: const Center(child: Text('오시 정보를 불러오는 데 실패했습니다.')),
          );
        }

        final user = snapshot.data!;
        final profileImageUrl = getHighResImage(user.userProfileImageUrl);
        final bannerUrl = user.userProfileBannerUrl;

        return Scaffold(
          appBar: AppBar(
            title: const Text('오시 프로필'),
            centerTitle: true,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.primary,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: bannerUrl != null
                          ? Image.network(
                          bannerUrl,
                          fit: BoxFit.cover
                      )
                          : Container(color: theme.colorScheme.surfaceContainerHighest),
                    ),
                    Positioned(
                      bottom: -40,
                      left: 20,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface
                          )
                      ),
                      const SizedBox(height: 4),
                      Text('@${user.tweetId}',
                          style: TextStyle(
                              fontSize: 15,
                              color: theme.colorScheme.onSurface.withAlpha(153),
                          )
                      ),
                      const SizedBox(height: 20),
                      BioBox(text: user.bio),
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
