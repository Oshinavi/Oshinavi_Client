import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mediaproject/main.dart';
import 'package:mediaproject/presentation/widgets/appbar/app_bar_drawer.dart';
import 'package:mediaproject/presentation/widgets/post/post_tile.dart';
import 'package:mediaproject/core/navigator/navigation_service.dart';
import 'package:mediaproject/presentation/views/home/oshi_profile_page.dart';
import 'package:mediaproject/presentation/views/home/profile_page.dart';
import 'package:mediaproject/presentation/views/auth/login_page.dart';
import 'package:mediaproject/presentation/views/auth/register_page.dart';
import 'package:mediaproject/presentation/views/schedule/monthly_calendar_page.dart';
import 'package:mediaproject/presentation/views/post/post_page.dart';
import 'package:mediaproject/presentation/providers/database_provider.dart';
import 'package:mediaproject/presentation/providers/oshi_provider.dart';
import 'package:mediaproject/presentation/providers/user_profile_provider.dart';
import 'package:mediaproject/domain/entities/post.dart';

/// HomePage:
/// - 사용자 별 등록된 ‘오시(Oshi)’ 정보를 로드하고 해당 오시의 게시글 목록을 페이징하여 보여줌
/// 주요 단계:
/// 1) initState: ScrollController 초기화 및 UserProfileProvider 통해 프로필 로드
/// 2) didChangeDependencies: Provider로부터 DatabaseProvider, OshiProvider 할당 및 _loadOshiAndPosts() 호출
/// 3) _loadOshiAndPosts: 오시 정보 로드 + 첫 페이지 게시물 로드 → _initialLoadDone=true로 상태 변경
/// 4) _onScroll: 리스트 하단 근접 시 _loadMorePosts 호출
/// 5) _loadMorePosts: 추가 페이지 로드
/// 6) build: 오시 등록 여부, 게시글 존재 여부에 따라 각기 다른 UI 반환
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

  bool _isInitialized = false; // 초기화 여부 플래그
  bool _isLoading = false;     // 로딩 중 표시 플래그
  bool _isLoadingMore = false; // 추가 로딩 중 표시 플래그
  bool _initialLoadDone = false; // 첫 로딩 완료 플래그

  String? _oshiTweetId;       // 등록된 오시 트위터 스크린네임
  String? _lastPushedRoute;   // 필수: didPushNext에서 저장하여 didPopNext 시 조건 검사

  @override
  void initState() {
    super.initState();

    // ScrollController: 스크롤 이벤트 리스너 등록
    _scrollController = ScrollController()..addListener(_onScroll);

    // 1) UserProfileProvider를 통해 유저 프로필 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileProvider>().loadProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // RouteObserver 구독: 다른 페이지에서 돌아왔을 때 didPopNext 호출
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute<dynamic>);

    // 2) 초기화되지 않았다면 Provider 할당 및 첫 로딩 수행
    if (!_isInitialized) {
      _databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      _oshiProvider = Provider.of<OshiProvider>(context, listen: false);
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
    // 새로운 페이지로 이동 시 호출 → 마지막 푸시된 라우트 저장
    _lastPushedRoute = ModalRoute.of(context)!.settings.name;
  }

  @override
  void didPopNext() {
    // 다른 페이지에서 돌아올 때마다 UserProfile 재로드 및 필요 시 포스트 재로드
    context.read<UserProfileProvider>().loadProfile();

    final reloadFrom = {
      OshiProfilePage.routeName,
      ProfilePage.routeName,
      MonthlyCalendarPage.routeName,
      LoginPage.routeName,
      RegisterPage.routeName,
    };
    if (reloadFrom.contains(_lastPushedRoute) && !_isLoading) {
      _loadOshiAndPosts();
    }
  }

  /// _loadOshiAndPosts:
  /// - OshiProvider.getOshi()로 오시 정보 조회
  /// - 오시가 등록되어 있으면 DatabaseProvider.loadAllPosts()로 첫 페이지 게시글 로드
  /// - 상태 변경: _isLoading=false, _initialLoadDone=true
  /// - UserProfileProvider.loadProfile() 호출하여 프로필 최신화
  Future<void> _loadOshiAndPosts() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final info = await _oshiProvider.getOshi();
      _oshiTweetId = info['oshi_tweet_id'] as String?;
      if (_oshiTweetId != null && _oshiTweetId!.isNotEmpty) {
        await _databaseProvider.loadAllPosts(_oshiTweetId!);
      }
    } catch (e) {
      debugPrint("오시 포스트 로드 오류: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _initialLoadDone = true;
      });
      await context.read<UserProfileProvider>().loadProfile();
    }
  }

  /// _onScroll:
  /// - 리스트가 하단에 가까워졌는지 감지하여 _loadMorePosts 호출
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _oshiTweetId != null) {
      _loadMorePosts();
    }
  }

  /// _loadMorePosts:
  /// - 추가 게시글 요청 (페이징) → DatabaseProvider.loadMorePosts 호출
  /// - 로딩 상태 토글 및 catch 블록에서 에러 로그 출력
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || _oshiTweetId == null) return;
    setState(() => _isLoadingMore = true);

    try {
      await _databaseProvider.loadMorePosts(_oshiTweetId!);
    } catch (e) {
      debugPrint('추가 포스트 로드 오류: $e');
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
      drawer: const AppBarDrawer(),
      // 6) 드로어 열림 시 UserProfileProvider.reload 호출
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          context.read<UserProfileProvider>().loadProfile();
        }
      },
      appBar: AppBar(title: const Text("홈")),

      body: RefreshIndicator(
        onRefresh: _loadOshiAndPosts,
        displacement: 16,
        // 7) 초기 로딩 중이면 로딩 인디케이터 화면
        child: (!_initialLoadDone && _isLoading)
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        )
            : _buildBody(theme, posts), // 정상 화면 빌드
      ),
    );
  }

  /// _buildBody:
  /// - 오시 등록 여부 및 게시글 목록 유무에 따라 다른 UI 반환
  ///  1) _oshiTweetId null/빈 문자열: 오시 미등록 상태 UI
  ///  2) posts.isEmpty: 등록은 되었으나 게시글 없음 UI
  ///  3) 그렇지 않으면 게시글 리스트 및 페이징 인디케이터 표시
  Widget _buildBody(ThemeData theme, List<Post> posts) {
    final availableHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    // 1) 오시 미등록 상태: 등록 버튼 UI 표시
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
                  Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '아직 등록된 오시가 없어요',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      NavigationService().navigateTo(
                        OshiProfilePage.routeName,
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('오시 등록하러 가기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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

    // 2) 등록됐지만 포스트 없음: '트윗이 없습니다...' 메시지 표시
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
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '트윗이 없습니다...',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 3) 포스트가 있을 때: ListView.separated로 페이징 및 로딩 인디케이터 표시
    final isDark = theme.brightness == Brightness.dark;
    final separatorColor = isDark
        ? theme.dividerColor.withAlpha(77)
        : Colors.grey.shade400;

    return ListView.separated(
      key: const PageStorageKey('home_posts_list'),
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (ctx, i) {
        if (i == posts.length) {
          // 3-1) 추가 로딩 스피너
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final post = posts[i];
        return PostTile(
          post: post,
          onUserTap: () {
            // 게시글 작성자 프로필로 이동
            NavigationService().navigateTo(
              ProfilePage.routeName,
              arguments: post.uid,
            );
          },
          onPostTap: () {
            // 포스트 상세 화면으로 이동
            NavigationService().navigateTo(
              PostPage.routeName,
              arguments: post,
            );
          },
          onReplySent: null,   // 홈 화면에서는 리플라이 입력창 감춤
          onPostPage: false,
          oshiTweetId: _oshiTweetId,
        );
      },
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
        color: separatorColor,
      ),
    );
  }
}