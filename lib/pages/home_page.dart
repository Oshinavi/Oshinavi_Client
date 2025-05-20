// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/main.dart';
import 'package:mediaproject/components/appbardrawer.dart';
import 'package:mediaproject/components/post_tile.dart';
import 'package:mediaproject/helper/navigates_pages.dart';
import 'package:mediaproject/pages/oshi_profile_page.dart';
import 'package:mediaproject/pages/profile_page.dart';
import 'package:mediaproject/pages/register_page.dart';
import 'package:mediaproject/pages/calendar_page.dart';
import 'package:mediaproject/pages/login_page.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/oshi_provider.dart';

import '../providers/user_profile_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/homepage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late DatabaseProvider _databaseProvider;
  late OshiProvider _oshiProvider;
  late ScrollController _scrollController;

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _initialLoadDone = false;

  String? _oshiTweetId;
  String? _lastPushedRoute;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadProfile();
    });
  }


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
    _scrollController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    _lastPushedRoute = ModalRoute.of(context)!.settings.name;
  }

  @override
  void didPopNext() {
    context.read<UserProfileProvider>().loadProfile();
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
      setState(() {
        _isLoading = false;
        _initialLoadDone = true;
      }
      );
      await context.read<UserProfileProvider>().loadProfile();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _oshiTweetId != null) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _oshiTweetId == null) return;
    setState(() => _isLoadingMore = true);
    try {
      await _databaseProvider.loadMorePosts(_oshiTweetId!);
    } catch (e) {
      debugPrint("❌ 추가 포스트 로드 오류: $e");
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final posts = context.watch<DatabaseProvider>().allPosts;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppBarDrawer(),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          context.read<UserProfileProvider>().loadProfile();
        }
      },
      appBar: AppBar(title: const Text("홈")),
      body: RefreshIndicator(
        onRefresh: _loadOshiAndPosts,
        displacement: 16,
        child: !_initialLoadDone && _isLoading
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        )
            : _buildBody(theme, posts),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, List posts) {
    final availableHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    // ① 오시 미등록
    if (_oshiTweetId == null || _oshiTweetId!.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: availableHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 48, color: theme.primaryColor),
                  const SizedBox(height: 12),
                  Text('아직 등록된 오시가 없어요', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: OshiProfilePage.routeName),
                          builder: (_) => const OshiProfilePage(),
                        ),
                      );
                    },
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
            ),
          ),
        ],
      );
    }

    // ② 오시는 등록됐지만 포스트가 없는 상태
    if (posts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: availableHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: theme.primaryColor),
                  const SizedBox(height: 12),
                  Text('트윗이 없습니다...', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // ③ 포스트가 있을 때
    return ListView.separated(
      key: const PageStorageKey('home_posts_list'),
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
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
