import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/components/bio_box.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/oshi_service.dart';

class OshiProfilePage extends StatefulWidget {
  const OshiProfilePage({super.key});

  @override
  State<OshiProfilePage> createState() => _OshiProfilePageState();
}

class _OshiProfilePageState extends State<OshiProfilePage> {
  Map<String, dynamic>? oshi;
  bool _isLoading = true;
  bool _initialized = false;

  // 등록용 컨트롤러 & 로딩 플래그
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
    setState(() {
      _isLoading = true;
    });
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

    setState(() {
      _isRegistering = true;
    });
    final result = await OshiService().registerOshi(inputId);
    setState(() {
      _isRegistering = false;
    });

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("존재하지 않는 ID입니다. 다시 한 번 확인해 주세요")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("최애 등록에 성공했어요!")),
      );
      await loadOshi();
    }
  }

  String? getHighResImage(String? url) {
    if (url == null) return null;
    return url.replaceAll('_normal', '_400x400');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1) 로딩 중
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2) 등록된 오시가 없을 때 → 인라인 입력 UI
    if (oshi == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("오시 프로필")),
        body: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text("아직 등록된 오시가 없어요", style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _registerController,
                    decoration: const InputDecoration(
                      labelText: "트위터 ID 입력",
                      hintText: "예: my_favorite_id",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isRegistering ? null : _registerOshi,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isRegistering
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text("오시 등록"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 3) 등록된 오시가 있을 때 → 프로필 화면
    return FutureBuilder(
      future: Provider.of<DatabaseProvider>(context, listen: false)
          .getUserProfile(oshi!["oshi_tweet_id"]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("오시 프로필")),
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
                        errorBuilder: (_, __, ___) =>
                            Container(color: theme.colorScheme.surfaceVariant),
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
                        backgroundImage:
                        profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
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