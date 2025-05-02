import 'package:flutter/material.dart';
import 'package:mediaproject/components/appbardrawer.dart';
import 'package:mediaproject/components/post_tile.dart';
import 'package:mediaproject/helper/navigates_pages.dart';
import 'package:mediaproject/main.dart';
import 'package:mediaproject/models/post.dart';
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
  String? _oshiUsername;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    if (!_isInitialized) {
      databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      oshiProvider = Provider.of<OshiProvider>(context, listen: false);
      loadOshiPosts();
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
    if (!_isLoading) {
      loadOshiPosts();
    }
  }

  Future<void> loadOshiPosts() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final oshiInfo = await oshiProvider.getOshi();
      print("📦 받은 오시 정보: $oshiInfo");
      _oshiTweetId = oshiInfo['oshi_tweet_id'];
      _oshiUsername = oshiInfo['oshi_username'];

      if (_oshiTweetId != null && _oshiTweetId is String) {
        print("📨 오시 트윗 ID로 포스트 요청: $_oshiTweetId");
        await databaseProvider.loadAllPosts(_oshiTweetId!);
        print("📥 로드된 포스트 수: ${databaseProvider.allPosts.length}");
      } else {
        print("⚠️ 오시 정보가 없거나 잘못되었습니다: $oshiInfo");
      }
    } catch (e) {
      print("❌ 오류 발생: $e");
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: AppBarDrawer(),
      appBar: AppBar(
        title: const Text("홈"),
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildPostList(listeningProvider.allPosts),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? const Center(child: Text("트윗이 없습니다..."))
        : ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostTile(
          post: post,
          onUserTap: () => goUserPage(context, post.uid),
          onPostTap: () => goPostPage(context, post),
          oshiProvider: oshiProvider,
          onPostPage: false,
          oshiUserId: _oshiTweetId,
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
        color: Theme.of(context).dividerColor.withOpacity(0.3),
      ),
    );
  }
}