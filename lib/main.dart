import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'core/navigator/navigation_service.dart';
import 'themes/theme_provider.dart';

// ViewModel imports
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/tweet_viewmodel.dart';
import 'presentation/viewmodels/oshi_viewmodel.dart';
import 'presentation/viewmodels/profile_viewmodel.dart';
import 'presentation/viewmodels/schedule_viewmodel.dart';

// UseCase imports
import 'domain/usecases/auth_usecase.dart';
import 'domain/usecases/fetch_posts_usecase.dart';
import 'domain/usecases/fetch_replies_usecase.dart';
import 'domain/usecases/fetch_user_profile_usecase.dart';
import 'domain/usecases/oshi_management_usecase.dart';
import 'domain/usecases/manage_schedule_usecase.dart';

// Repository imports
import 'domain/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/database_repository.dart';
import 'data/repositories/database_repository_impl.dart';
import 'domain/repositories/tweet_repository.dart';
import 'data/repositories/tweet_repository_impl.dart';
import 'domain/repositories/oshi_repository.dart';
import 'data/repositories/oshi_repository_impl.dart';
import 'domain/repositories/schedule_repository.dart';
import 'data/repositories/schedule_repository_impl.dart';

// Provider(서비스) imports
import 'presentation/providers/database_provider.dart';
import 'presentation/providers/oshi_provider.dart';
import 'presentation/providers/user_profile_provider.dart';

// View(화면) imports
import 'presentation/views/auth/auth_gate_page.dart';
import 'presentation/views/auth/login_page.dart';
import 'presentation/views/auth/register_page.dart';
import 'presentation/views/home/home_page.dart';
import 'presentation/views/home/profile_page.dart';
import 'presentation/views/home/oshi_profile_page.dart';
import 'presentation/views/schedule/monthly_calendar_page.dart';
import 'presentation/views/schedule/event_detail_page.dart';
import 'presentation/views/settings/settings_page.dart';
import 'presentation/views/post/post_page.dart';
import 'presentation/views/home/image_preview_page.dart';

// 엔티티·모델 imports
import 'data/models/schedule_model.dart';
import 'domain/entities/post.dart';

/// 전역 RouteObserver:
/// - Navigator의 페이지 전환 이벤트를 감지하기 위해 사용
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 1) Native Splash 화면을 남겨두고 첫 프레임 렌더링 대기
  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  final navigationService = NavigationService();

  runApp(
    MultiProvider(
      providers: [
        // 2) 테마 프로바이더 등록
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // ── Repository 레이어 (인터페이스 ↔ 구현체) ──
        Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        Provider<DatabaseRepository>(create: (_) => DatabaseRepositoryImpl()),
        Provider<TweetRepository>(create: (_) => TweetRepositoryImpl()),
        Provider<OshiRepository>(create: (_) => OshiRepositoryImpl()),
        Provider<ScheduleRepository>(create: (_) => ScheduleRepositoryImpl()),

        // ── UseCase 레이어 ──
        Provider<AuthUseCase>(
          create: (ctx) => AuthUseCase(ctx.read<AuthRepository>()),
        ),
        Provider<FetchPostsUseCase>(
          create: (ctx) => FetchPostsUseCase(ctx.read<DatabaseRepository>()),
        ),
        Provider<FetchRepliesUseCase>(
          create: (ctx) => FetchRepliesUseCase(ctx.read<TweetRepository>()),
        ),
        Provider<FetchUserProfileUseCase>(
          create: (ctx) => FetchUserProfileUseCase(ctx.read<DatabaseRepository>()),
        ),
        Provider<OshiManagementUseCase>(
          create: (ctx) => OshiManagementUseCase(ctx.read<OshiRepository>()),
        ),
        Provider<ManageScheduleUseCase>(
          create: (ctx) => ManageScheduleUseCase(ctx.read<ScheduleRepository>()),
        ),

        // ── ViewModel 레이어 ──
        ChangeNotifierProvider<AuthViewModel>(
          create: (ctx) => AuthViewModel(useCase: ctx.read<AuthUseCase>()),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (ctx) => HomeViewModel(
            oshiUseCase: ctx.read<OshiManagementUseCase>(),
            postUseCase: ctx.read<FetchPostsUseCase>(),
          ),
        ),
        ChangeNotifierProvider<TweetViewModel>(
          create: (ctx) => TweetViewModel(
            fetchRepliesUseCase: ctx.read<FetchRepliesUseCase>(),
            tweetRepository: ctx.read<TweetRepository>(),
          ),
        ),
        ChangeNotifierProvider<OshiViewModel>(
          create: (ctx) => OshiViewModel(useCase: ctx.read<OshiManagementUseCase>()),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (ctx) =>
              ProfileViewModel(useCase: ctx.read<FetchUserProfileUseCase>()),
        ),
        ChangeNotifierProvider<ScheduleViewModel>(
          create: (ctx) => ScheduleViewModel(useCase: ctx.read<ManageScheduleUseCase>()),
        ),

        // ── 서비스(Provider) 레이어 ──
        ChangeNotifierProvider<DatabaseProvider>(
          create: (_) => DatabaseProvider(),
        ),
        ChangeNotifierProvider<OshiProvider>(
          create: (_) => OshiProvider(),
        ),

        // ── UserProfileProvider 등록 ──
        ChangeNotifierProvider<UserProfileProvider>(
          create: (ctx) => UserProfileProvider(
            authUseCase: ctx.read<AuthUseCase>(),
            fetchProfileUseCase: ctx.read<FetchUserProfileUseCase>(),
          ),
        ),
      ],
      child: MyApp(navigationService: navigationService),
    ),
  );
}

/// MyApp:
/// - MaterialApp을 래핑하고, 테마, 네비게이터 키/옵저버, 로컬라이제이션, 라우트 설정을 담당
class MyApp extends StatefulWidget {
  final NavigationService navigationService;

  const MyApp({Key? key, required this.navigationService}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // 1) 첫 프레임 이후 300ms 딜레이 후, opacity를 1로 변경하여
    //    페이드인 효과 주고 Native Splash 제거
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => _opacity = 1);
        FlutterNativeSplash.remove();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 300),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        navigatorKey: widget.navigationService.key,
        theme: themeProvider.themeData,

        // Localization 설정
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ko', 'KR'),

        // ── 라우트 설정 ──
        initialRoute: '/auth_gate',
        routes: {
          // 1) 인증 게이트 (로그인/회원가입 여부에 따라 화면 분기)
          '/auth_gate': (_) => const AuthGatePage(),

          // 2) 로그인 / 회원가입
          '/login': (ctx) => LoginPage(
            toggleToRegister: () {
              Navigator.pushReplacementNamed(ctx, '/register');
            },
          ),
          '/register': (ctx) => RegisterPage(
            onTap: () {
              Navigator.pushReplacementNamed(ctx, '/login');
            },
          ),

          // 3) 홈 화면
          '/home': (_) => const HomePage(),

          // 4) 프로필 화면 (arguments: tweetId:String)
          '/profile': (ctx) {
            final tweetId = ModalRoute.of(ctx)!.settings.arguments as String;
            return ProfilePage(tweetId: tweetId);
          },

          // 5) 오시 관리 화면
          '/oshi_profile': (_) => const OshiProfilePage(),

          // 6) 달력 화면
          '/monthly_calendar': (_) => const MonthlyCalendarPage(),

          // 7) 일정 상세 화면 (arguments: ScheduleModel)
          '/event_detail': (ctx) {
            final scheduleModel =
            ModalRoute.of(ctx)!.settings.arguments as ScheduleModel;
            return EventDetailPage(schedule: scheduleModel);
          },

          // 8) 설정 화면
          '/settings': (_) => const SettingsPage(),

          // 9) 포스트 상세 화면 (arguments: Post)
          '/post': (ctx) {
            final post = ModalRoute.of(ctx)!.settings.arguments as Post;
            final homeVm = Provider.of<HomeViewModel>(ctx, listen: false);
            final oshiTweetId = homeVm.oshiProfile?.tweetId;
            return PostPage(post: post, oshiTweetId: oshiTweetId);
          },

          // 10) 이미지 미리보기 (arguments: Map<String,String>)
          '/image_preview': (ctx) {
            final args =
            ModalRoute.of(ctx)!.settings.arguments as Map<String, String>;
            return ImagePreviewPage(
              imageUrl: args['imageUrl']!,
              tag: args['tag']!,
            );
          },
        },
      ),
    );
  }
}