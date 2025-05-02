import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:characters/characters.dart';
import 'package:mediaproject/models/post.dart';
import 'package:mediaproject/services/oshi_provider.dart';
import 'package:mediaproject/services/tweet_provider.dart';
import 'package:provider/provider.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;
  final OshiProvider oshiProvider;
  final bool onPostPage;
  final String? oshiUserId;

  const PostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
    required this.oshiProvider,
    this.onPostPage = false,
    required this.oshiUserId,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  final TextEditingController _replyController = TextEditingController();
  int _replyByteCount = 0;
  bool _isLoadingAutoReply = false;

  void _updateLength(String text) {
    int count = 0;
    for (final char in text.characters) {
      if (RegExp(r'^[\x00-\x7F]$').hasMatch(char)) {
        count += 1; // ASCII 문자 (영문, 숫자, 공백, 개행 등)
      } else {
        count += 2; // 그 외 문자 및 이모지
      }
    }
    setState(() {
      _replyByteCount = count;
    });
  }

  Future<void> _handleAutoReply() async {
    setState(() => _isLoadingAutoReply = true);
    try {
      final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
      final reply = await tweetProvider.generateAutoReply(widget.post.message);

      if (reply != null) {
        _replyController.text = "";
        for (final char in reply.characters) {
          await Future.delayed(const Duration(milliseconds: 30));
          _replyController.text += char;
          _replyController.selection = TextSelection.fromPosition(
            TextPosition(offset: _replyController.text.length),
          );
          _updateLength(_replyController.text);
        }
      }
    } catch (e) {
      print("❌ 자동 생성 실패: $e");
    } finally {
      setState(() => _isLoadingAutoReply = false);
    }
  }

  Future<void> _handleReplySubmit() async {
    final replyText = _replyController.text.trim();

    if (_replyByteCount > 280) {
      _showDialog("エラー", "文字数が多すぎます（最大280文字）");
      return;
    }

    final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
    final success = await tweetProvider.sendReply(
      tweetId: widget.post.id,
      replyText: replyText,
    );

    if (success) {
      _replyController.clear();
      setState(() => _replyByteCount = 0);
      _showDialog("完了", "リプライが送信されました。");
    } else {
      _showDialog("エラー", tweetProvider.lastErrorMessage ?? "送信に失敗しました。");
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("일정 추출"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text("취소"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final profileImageUrl = post.profileImageUrl?.replaceAll('_normal', '_400x400');

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    child: profileImageUrl == null ? Icon(Icons.person, color: theme.colorScheme.primary) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onUserTap,
                    child: widget.onPostPage
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.username, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
                        Text('@${widget.oshiUserId ?? post.uid}', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                      ],
                    )
                        : Row(
                      children: [
                        Text(post.username, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
                        const SizedBox(width: 6),
                        if (widget.oshiUserId != null)
                          Text('@${widget.oshiUserId}', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showOptions,
                  child: Icon(Icons.more_horiz, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(post.translatedMessage, style: TextStyle(fontSize: 16.5, height: 1.6, color: theme.colorScheme.onSurface)),
            if (widget.onPostPage)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  DateFormat('yyyy년 MM월 dd일 HH:mm').format(post.date),
                  style: TextStyle(fontSize: 13.5, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              ),
            if (widget.onPostPage) ...[
              const Divider(height: 32),
              TextField(
                controller: _replyController,
                maxLines: null,
                onChanged: _updateLength,
                decoration: InputDecoration(
                  hintText: "返信を入力...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("残り文字数: ${280 - _replyByteCount}", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoadingAutoReply ? null : _handleAutoReply,
                        child: _isLoadingAutoReply
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text("自動生成"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _handleReplySubmit,
                        style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
                        child: const Text("送信"),
                      ),
                    ],
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}