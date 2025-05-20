import 'package:flutter/material.dart';
import 'package:mediaproject/components/post_tile.dart';
import 'package:mediaproject/helper/navigates_pages.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/models/reply.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'package:mediaproject/services/tweet_provider.dart';
import 'package:provider/provider.dart';

import '../components/reply_tile.dart';

class PostPage extends StatefulWidget {
  final Post post;
  final OshiProvider oshiProvider;
  static const routeName = '/post';

  const PostPage({
    super.key,
    required this.post,
    required this.oshiProvider,
  });

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String? _oshiUserId;
  bool _isLoadingPost = true;
  bool _isLoadingReplies = true;
  List<Reply> _replies = [];

  @override
  void initState() {
    super.initState();
    _loadOshi();
    _loadReplies();
  }

  Future<void> _loadOshi() async {
    final info = await widget.oshiProvider.getOshi();
    setState(() {
      _oshiUserId = info['oshi_tweet_id'] as String?;
      _isLoadingPost = false;
    });
  }

  Future<void> _loadReplies() async {
    try {
      final tp = Provider.of<TweetProvider>(context, listen: false);
      final list = await tp.fetchReplies(
        tweetId: widget.post.id.toString(),
      );
      setState(() => _replies = list);
    } catch (_) {
      // ignore
    } finally {
      setState(() => _isLoadingReplies = false);
    }
  }

  void _onReplySent(Reply newReply) {
    setState(() {
      _replies.insert(0, newReply);
    });
  }

  Future<void> _confirmDelete(Reply reply) async {
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
      final tp = Provider.of<TweetProvider>(context, listen: false);
      await tp.deleteReply(replyId: reply.id.toString());
      setState(() {
        _replies.removeWhere((r) => r.id == reply.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
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
            // Post + input
            PostTile(
              post: post,
              onUserTap: () => goUserPage(context, post.uid),
              onPostTap: null,
              onReplySent: _onReplySent,
              oshiProvider: widget.oshiProvider,
              onPostPage: true,
              oshiUserId: _oshiUserId,
            ),

            // 분리선
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 16),

            // Replies heading
            Text('리플라이', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            // Replies list
            if (_isLoadingReplies)
              const Center(child: CircularProgressIndicator())
            else if (_replies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '아직 리플라이가 없습니다',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else ...[
                ReplyTile(
                  reply: _replies.first,
                  onDelete: () => _confirmDelete(_replies.first),
                ),
                const SizedBox(height: 8),
                ..._replies.skip(2).map(
                      (r) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ReplyTile(
                      reply: r,
                      onDelete: () => _confirmDelete(r),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }
}