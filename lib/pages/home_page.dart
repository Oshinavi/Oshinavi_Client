import 'package:flutter/material.dart';
import 'package:mediaproject/components/appbardrawer.dart';
import 'package:mediaproject/main.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/services/databases/database_provider.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'oshi_profile_page.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware{
  late DatabaseProvider databaseProvider;
  late OshiProvider oshiProvider;
  bool _isInitialized = false; // ✅ 중복 방지용 플래그

  // Map<String, dynamic>? oshi;
  //
  // final _messageController = TextEditingController();
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // PostFrameCallback을 사용하여 context 안전하게 접근
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
  //     oshiProvider = Provider.of<OshiProvider>(context, listen: false);
  //     loadOshiPosts();
  //   });
  // }


  //
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_isInitialized) {
  //     databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
  //     oshiProvider = Provider.of<OshiProvider>(context, listen: false);
  //     loadOshiPosts();
  //     _isInitialized = true;
  //   }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    if (!_isInitialized) {
      databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      oshiProvider = Provider.of<OshiProvider>(context, listen: false);
      loadOshiPosts(); // ✅ 한 번만 실행
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // 해제
    super.dispose();
  }

  @override
  void didPopNext() {
    // 다른 페이지에서 돌아왔을 때 호출됨
    loadOshiPosts();
  }

  Future<void> loadOshiPosts() async {
    // 오시의 트윗 ID 가져오기
    final oshiInfo = await oshiProvider.getOshi();
    print("📦 받은 오시 정보: $oshiInfo"); // 추가
    final oshiTweetId = oshiInfo['oshi_tweet_id'];

    if (oshiTweetId != null && oshiTweetId is String) {
      print("📨 오시 트윗 ID로 포스트 요청: $oshiTweetId"); // 추가
      await databaseProvider.loadAllPosts(oshiTweetId);
      print("📥 로드된 포스트 수: ${databaseProvider.allPosts.length}"); // 추가
    } else {
      print("⚠️ 오시 정보가 없거나 잘못되었습니다: $oshiInfo");
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
        : ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.message, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(post.translatedMessage),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:mediaproject/components/appbardrawer.dart';
// import 'package:mediaproject/models/post.dart';
// import 'package:mediaproject/services/databases/database_provider.dart';
// import 'package:provider/provider.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   // providers
//   late final listeningProvider = Provider.of<DatabaseProvider>(context);
//   late final databaseProvider =
//   Provider.of<DatabaseProvider>(context, listen: false);
//
//   // text controllers
//   final _messageController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     loadAllPosts();
//   }
//
//   Future<void> loadAllPosts() async {
//     await databaseProvider.loadAllPosts();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       drawer: AppBarDrawer(),
//       appBar: AppBar(
//         title: const Text("홈"),
//         foregroundColor: Theme.of(context).colorScheme.inversePrimary,
//       ),
//       body: _buildPostList(listeningProvider.allPosts),
//     );
//   }
//
//   Widget _buildPostList(List<Post> posts) {
//     return posts.isEmpty
//         ? const Center(
//       child: Text("트윗이 없습니다..."),
//     )
//         : ListView.builder(
//       itemCount: posts.length,
//       itemBuilder: (context, index) {
//         final post = posts[index];
//         return Container(
//           child: Text(post.message),
//         );
//       },
//     );
//   }
// }