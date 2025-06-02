import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/oshi_viewmodel.dart';
import '../../widgets/common/bio_box.dart';

/// OshiProfilePage:
/// - 사용자(팬)가 등록한 ‘오시’ 프로필 정보 조회/등록/변경/삭제 화면
/// 주요 단계:
/// 1) didChangeDependencies에서 ViewModel.loadOshi() 호출하여 초기 데이터 로드
/// 2) 오시 미등록 상태 → 트위터 ID 입력창 + 등록 버튼 화면 표시
/// 3) 오시 등록되어 있는데 프로필 로딩 중 → 로딩 인디케이터
/// 4) 오시 프로필 로딩 완료 → 배너, 프로필 사진, 이름, 팔로잉/팔로워 수, 바이오 정보 표시
/// 5) ‘변경’ 버튼 클릭 시 _onChange() 호출 → 트위터 ID 변경 다이얼로그 → ViewModel.registerOshi() 호출
/// 6) ‘삭제’ 버튼 클릭 시 _onDelete() 호출 → 확인 다이얼로그 → ViewModel.deleteOshi() 호출
class OshiProfilePage extends StatefulWidget {
  const OshiProfilePage({Key? key}) : super(key: key);
  static const routeName = '/oshi_profile';

  @override
  State<OshiProfilePage> createState() => _OshiProfilePageState();
}

class _OshiProfilePageState extends State<OshiProfilePage> {
  bool _initialized = false;                  // 초기 로드 여부
  final TextEditingController _registerController = TextEditingController();
  bool _isRegistering = false;                // 등록 버튼 로딩 상태

  @override
  void dispose() {
    _registerController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // 1) ViewModel.loadOshi 호출하여 서버에서 오시 정보 가져오기
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<OshiViewModel>().loadOshi();
      });
    }
  }

  /// _onRegister:
  /// - 입력된 _registerController.text를 사용해 ViewModel.registerOshi 호출
  /// - 등록 성공 시 SnackBar, 실패 시 AlertDialog 표시 후 ViewModel.loadOshi 재호출
  Future<void> _onRegister() async {
    final inputId = _registerController.text.trim();
    if (inputId.isEmpty) return;

    setState(() => _isRegistering = true);
    final vm = context.read<OshiViewModel>();
    await vm.registerOshi(inputId);
    setState(() => _isRegistering = false);

    if (vm.errorMessage != null) {
      // 2) 등록 실패 → AlertDialog 표시
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('오류'),
          content: Text(vm.errorMessage!),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
      return;
    }

    // 3) 등록 성공 → SnackBar + ViewModel.loadOshi으로 최신 정보 로드
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('오시 등록 성공')));
    await vm.loadOshi();
  }

  /// _onChange:
  /// - 현재 등록된 오시 ID를 다이얼로그에 보여주고 변경된 새로운 ID가 입력되면 ViewModel.registerOshi 호출
  /// - 에러 시 AlertDialog, 성공 시 SnackBar + ViewModel.loadOshi
  Future<void> _onChange() async {
    final vm = context.read<OshiViewModel>();
    final currentId = vm.currentOshiTweetId ?? '';
    final newId = await showDialog<String>(
      context: context,
      builder: (ctx) => _OshiChangeDialog(initial: currentId),
    );
    if (newId == null || newId.isEmpty) return;

    await vm.registerOshi(newId);
    if (vm.errorMessage != null) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('오류'),
          content: Text(vm.errorMessage!),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('오시 변경 완료')));
      await vm.loadOshi();
    }
  }

  /// _onDelete:
  /// - 등록된 오시 삭제 확인 다이얼로그 표시
  /// - 확인 시 ViewModel.deleteOshi 호출
  /// - 실패 시 SnackBar, 성공 시 SnackBar + ViewModel.loadOshi
  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('오시 삭제'),
        content: const Text('정말 등록된 오시를 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final vm = context.read<OshiViewModel>();
    await vm.deleteOshi();
    if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('오시 삭제 실패')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('오시 삭제 완료')));
      await vm.loadOshi();
    }
  }

  /// _getHighResImage:
  /// - 트위터 프로필 이미지 URL에서 "_normal"을 "_400x400"으로 변경하여 고해상도 버전 사용
  String? _getHighResImage(String? url) => url?.replaceAll('_normal', '_400x400');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<OshiViewModel>(
      builder: (ctx, vm, _) {
        // 4) 로딩 중일 때 로딩 인디케이터 표시
        if (vm.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final screenId = vm.currentOshiTweetId ?? '';
        // 5) 오시 미등록 상태: 입력창 + 등록 버튼
        if (screenId.isEmpty) {
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
                          hintText: '예: cocona_nonaka',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isRegistering ? null : _onRegister,
                          child: _isRegistering
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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

        // 6) 오시 등록됐으나 프로필 로딩 중일 때 로딩 인디케이터
        final profile = vm.oshiProfile;
        if (profile == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 7) 오시 프로필 화면: 배너, 프로필 이미지, 상세 정보 표시
        final bannerUrl = profile.userProfileBannerUrl;
        final avatarUrl = _getHighResImage(profile.userProfileImageUrl);

        return Scaffold(
          appBar: AppBar(title: const Text('오시 프로필')),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 배너 + 프로필 이미지
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: bannerUrl != null
                          ? Image.network(
                        bannerUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                          : null,
                    ),
                    Positioned(
                      top: 150,
                      left: 16,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 사용자 이름 및 스크린네임
                      Text(
                        profile.username,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${profile.tweetId}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 12),

                      // 팔로우 상태 버튼, 변경 버튼, 삭제 버튼
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: theme.colorScheme.onPrimary,
                              foregroundColor: theme.colorScheme.primary,
                            ),
                            child: const Text('팔로우 중'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _onChange,
                            style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                            child: const Text('변경'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _onDelete,
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              side: BorderSide(color: Colors.redAccent),
                            ),
                            child: const Text('삭제', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 팔로잉·팔로워 수 표시
                      Row(
                        children: [
                          Text(
                            '${profile.followingCount} 팔로잉',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${profile.followersCount} 팔로워',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 바이오 정보가 있으면 BioBox 표시
                      if (profile.bio != null && profile.bio!.trim().isNotEmpty)
                        BioBox(text: profile.bio!),
                      const SizedBox(height: 16),
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

/// _OshiChangeDialog:
/// - AlertDialog로 트위터 ID를 입력받아 반환
class _OshiChangeDialog extends StatefulWidget {
  final String initial; // 초기값으로 현재 등록된 ID 표시
  const _OshiChangeDialog({required this.initial});

  @override
  State<_OshiChangeDialog> createState() => _OshiChangeDialogState();
}

class _OshiChangeDialogState extends State<_OshiChangeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 초기 컨트롤러 값 설정
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('오시 변경'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: '트위터 ID',
          hintText: '예: cocona_nonaka',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('변경'),
        ),
      ],
    );
  }
}