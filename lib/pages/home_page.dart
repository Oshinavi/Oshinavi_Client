import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/main.dart';
import 'package:mediaproject/components/appbardrawer.dart';
import 'package:mediaproject/components/post_tile.dart';
import 'package:mediaproject/helper/navigates_pages.dart';
import 'package:mediaproject/pages/oshi_profile_page.dart';
import 'package:mediaproject/pages/profile_page.dart';     // ← ProfilePage
import 'package:mediaproject/pages/register_page.dart';    // ← RegisterPage
import 'package:mediaproject/pages/calendar_page.dart';    // ← CalendarPage
import 'package:mediaproject/pages/login_page.dart';       // ← LoginPage
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/oshi_provider.dart';

import 'image_preview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/homepage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late DatabaseProvider _databaseProvider;
  late OshiProvider _oshiProvider;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _oshiTweetId;
  String? _lastPushedRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    if (!_isInitialized) {
      _databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      _oshiProvider     = Provider.of<OshiProvider>(context, listen: false);
      _loadOshiAndPosts();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    // 다음에 어떤 페이지가 올라갔는지 기록해 둠
    _lastPushedRoute = ModalRoute.of(context)!.settings.name;
  }

  @override
  void didPopNext() {
    const reloadFrom = {
      OshiProfilePage.routeName,
      ProfilePage.routeName,
      CalendarPage.routeName,
      LoginPage.routeName,
      RegisterPage.routeName,
    };
    if (reloadFrom.contains(_lastPushedRoute) && !_isLoading) {
      _loadOshiAndPosts();
    }
  }

  Future<void> _loadOshiAndPosts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final info = await _oshiProvider.getOshi();
      _oshiTweetId = info['oshi_tweet_id'] as String?;
      if (_oshiTweetId != null) {
        await _databaseProvider.loadAllPosts(_oshiTweetId!);
      }
    } catch (e) {
      debugPrint("❌ 오시 포스트 로드 오류: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posts = context.watch<DatabaseProvider>().allPosts;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppBarDrawer(),
      appBar: AppBar(title: const Text("홈")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(theme, posts),
    );
  }

  Widget _buildBody(ThemeData theme, List posts) {
    if (_oshiTweetId == null || _oshiTweetId!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 48, color: theme.primaryColor),
            const SizedBox(height: 12),
            Text('아직 등록된 오시가 없어요', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    settings: RouteSettings(name: OshiProfilePage.routeName),
                    builder: (_) => const OshiProfilePage()),
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('오시 등록하러 가기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                elevation: 2,
              ),
            ),
          ],
        ),
      );
    }

    if (posts.isEmpty) {
      return Center(
        child: Text(
          "트윗이 없습니다...",
          style: theme.textTheme.bodyMedium
              ?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153)
          ),
        ),
      );
    }

    return ListView.separated(
      key: const PageStorageKey('home_posts_list'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: posts.length,
      itemBuilder: (ctx, i) {
        final post = posts[i];
        return PostTile(
          post: post,
          onUserTap: () => goUserPage(context, post.uid),
          onPostTap: () => goPostPage(context, post),
          oshiProvider: _oshiProvider,
          onPostPage: false,
          oshiUserId: _oshiTweetId,
        );
      },
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
        color: theme.dividerColor.withAlpha(77),
      ),
    );
  }
}