import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/post/post_tile.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../viewmodels/tweet_viewmodel.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/entities/reply.dart';
import '../../widgets/common/reply_tile.dart';

/// PostPage:
/// - 선택한 단일 포스트와 해당 포스트의 리플라이(댓글)을 보여주는 화면
/// - TweetViewModel.loadReplies 호출하여 리플라이 로드
/// - 새 리플라이 작성 시 onReplySent 콜백으로 상단에 추가
///
/// 주요 단계:
/// 1) initState에서 TweetViewModel.loadReplies 호출
/// 2) 본문: PostTile -> 리플라이 입력 창 포함
/// 3) 이하 리플라이 목록: 첫 번째 리플라이에는 삭제 메뉴 포함, 나머지는 일반 목록
class PostPage extends StatefulWidget {
  static const routeName = '/post';

  final Post post;         // 표시할 포스트 엔티티
  final String? oshiTweetId; // 홈 화면에서 전달받은 오시 트위터 ID

  const PostPage({
    Key? key,
    required this.post,
    this.oshiTweetId,
  }) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late TweetViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<TweetViewModel>();
    // 1) 포스트 ID로 리플라이 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.loadReplies(widget.post.id);
    });
  }

  /// _confirmDeleteReply:
  /// - 리플라이 삭제 확인 다이얼로그 표시
  /// - 확인 시 TweetViewModel.deleteReply 호출
  Future<void> _confirmDeleteReply(Reply reply) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _vm.deleteReply(reply.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TweetViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('포스트'),
        foregroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // 2) PostTile: 본문 + 리플라이 입력 UI 포함 (onPostPage=true)
            PostTile(
              post: widget.post,
              onUserTap: () {
                Navigator.of(context)
                    .pushNamed('/profile', arguments: widget.post.uid);
              },
              onPostTap: null,
              onReplySent: (Reply newReply) {
                // 새 리플라이가 전송되면 리스트 상단에 추가
                setState(() {
                  vm.replies.insert(0, newReply);
                });
              },
              oshiTweetId: widget.oshiTweetId,
              onPostPage: true,
            ),

            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),

            // '리플라이' 제목
            Text('리플라이', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            // 3) 리플라이 로딩 중일 때 로딩 인디케이터
            if (vm.isLoadingReplies)
              const Center(child: LoadingIndicator())

            // 4) 리플라이가 하나도 없을 때
            else if (vm.replies.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('아직 리플라이가 없습니다', textAlign: TextAlign.center),
              )

            // 5) 하나 이상의 리플라이가 있을 때: 첫 번째 리플라이에는 삭제 메뉴 포함
            else ...[
                ReplyTile(
                  reply: vm.replies.first,
                  onDelete: () => _confirmDeleteReply(vm.replies.first),
                ),
                const SizedBox(height: 8),
                // 두 번째 이후 리플라이: 단순 목록
                ...vm.replies.skip(1).map((r) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ReplyTile(
                    reply: r,
                    onDelete: () => _confirmDeleteReply(r),
                  ),
                )),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }
}