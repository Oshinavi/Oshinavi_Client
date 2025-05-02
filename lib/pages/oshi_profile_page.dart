import 'package:flutter/material.dart';
import 'package:mediaproject/components/bio_box.dart';
import 'package:mediaproject/pages/oshi_register_page.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/oshi_service.dart';
import 'package:provider/provider.dart';

class OshiProfilePage extends StatefulWidget {
  const OshiProfilePage({super.key});

  @override
  State<OshiProfilePage> createState() => _OshiProfilePageState();
}

class _OshiProfilePageState extends State<OshiProfilePage> {
  Map<String, dynamic>? oshi;
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => loadOshi());
    }
  }

  Future<void> loadOshi() async {
    setState(() => _isLoading = true);
    final result = await OshiService().getOshi();

    if (mounted) {
      setState(() {
        _isLoading = false;
        oshi = result.containsKey('error') ? null : result;
      });
    }
  }

  String? getHighResImage(String? url) {
    if (url == null) return null;
    return url.replaceAll('_normal', '_400x400');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oshiProvider = Provider.of<DatabaseProvider>(context, listen: false);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (oshi == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("오시 정보")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("아직 오시를 등록하지 않으신 것 같아요!"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const OshiRegisterPage()),
                  );
                },
                child: const Text("오시 등록"),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder(
      future: oshiProvider.getUserProfile(oshi!["oshi_tweet_id"]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("오시 정보")),
            body: const Center(child: Text("오시 정보를 불러오는 데 실패했습니다.")),
          );
        }

        final user = snapshot.data!;
        final profileImageUrl = getHighResImage(user.userProfileImageUrl);
        final bannerUrl = user.userProfileBannerUrl;

        return Scaffold(
          appBar: AppBar(
            title: const Text("오시 프로필"),
            centerTitle: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 1,
            foregroundColor: theme.colorScheme.primary,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 배너 이미지 영역
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: bannerUrl != null
                          ? Image.network(
                        bannerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: theme.colorScheme.surfaceVariant,
                        ),
                      )
                          : Container(color: theme.colorScheme.surfaceVariant),
                    ),

                    // 프로필 이미지
                    Positioned(
                      bottom: -40,
                      left: 20,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl == null
                            ? Icon(Icons.person,
                            size: 48, color: theme.colorScheme.primary)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // 유저 정보
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.tweetId}',
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
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