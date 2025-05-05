import 'package:flutter/material.dart';
import 'package:mediaproject/components/appbardrawer.dart';
import 'package:mediaproject/components/post_tile.dart';
import 'package:mediaproject/helper/navigates_pages.dart';
import 'package:mediaproject/main.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late DatabaseProvider databaseProvider;
  late OshiProvider oshiProvider;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _oshiTweetId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    if (!_isInitialized) {
      databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      oshiProvider     = Provider.of<OshiProvider>(context, listen: false);
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
  void didPopNext() {
    if (!_isLoading) _loadOshiAndPosts();
  }

  Future<void> _loadOshiAndPosts() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final info = await oshiProvider.getOshi();
      _oshiTweetId = info['oshi_tweet_id'] as String?;
      if (_oshiTweetId != null) {
        await databaseProvider.loadAllPosts(_oshiTweetId!);
      }
    } catch (e) {
      print("❌ 오시 포스트 로드 오류: $e");
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<DatabaseProvider>().allPosts;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: AppBarDrawer(),  // const 제거
      appBar: AppBar(
        title: const Text("홈"),
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: posts.isEmpty
          ? const Center(child: Text("트윗이 없습니다..."))
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: posts.length,
        itemBuilder: (ctx, i) {
          final post = posts[i];
          return PostTile(
            post: post,
            onUserTap: () => goUserPage(context, post.uid),
            onPostTap: () => goPostPage(context, post),
            oshiProvider: oshiProvider,
            onPostPage: false,
            oshiUserId: _oshiTweetId,
          );
        },
        separatorBuilder: (_, __) => Divider(
          height: 1,
          thickness: 0.5,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
    );
  }
}