import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:characters/characters.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/post.dart';
import '../services/oshi_provider.dart';
import '../services/tweet_provider.dart';
import '../pages/image_preview_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;
  final OshiProvider oshiProvider;
  final bool onPostPage;
  final String? oshiUserId;

  const PostTile({
    Key? key,
    required this.post,
    this.onUserTap,
    this.onPostTap,
    required this.oshiProvider,
    this.onPostPage = false,
    required this.oshiUserId,
  }) : super(key: key);

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  final TextEditingController _replyController = TextEditingController();
  int _replyByteCount = 0;
  bool _isLoadingAutoReply = false;
  bool _isSendingReply = false;
  bool _showOriginal = false;

  // ────────────────────────────────────────────────────────────────────────
  // ★ 여기에 반드시 들어가야 하는 이미지 격자 헬퍼 메서드
  Widget _buildImageGrid(List<String> urls) {
    final display = urls.take(4).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: display.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: display.length == 1 ? 1 : 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ImagePreviewPage(
                imageUrl: display[i],
                tag: '${widget.post.id}_$i',
              ),
            ));
          },
          child: Hero(
            tag: '${widget.post.id}_$i',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                display[i],
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, prog) =>
                prog == null ? child : const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ────────────────────────────────────────────────────────────────────────

  void _updateLength(String text) {
    int count = 0;
    for (final ch in text.characters) {
      count += RegExp(r'^[\x00-\x7F]$').hasMatch(ch) ? 1 : 2;
    }
    setState(() => _replyByteCount = count);
  }

  Future<void> _handleAutoReply() async {
    setState(() => _isLoadingAutoReply = true);
    try {
      final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
      final reply = await tweetProvider.generateAutoReply(widget.post.message);
      if (reply != null) {
        _replyController.clear();
        for (final ch in reply.characters) {
          await Future.delayed(const Duration(milliseconds: 30));
          _replyController.text += ch;
          _replyController.selection = TextSelection.fromPosition(
            TextPosition(offset: _replyController.text.length),
          );
          _updateLength(_replyController.text);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("자동 생성 실패: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoadingAutoReply = false);
    }
  }

  Future<void> _handleReplySubmit() async {
    final replyText = _replyController.text.trim();
    if (_replyByteCount > 280) {
      _showDialog("에러", "글자수가 너무 많습니다（최대 280자）");
      return;
    }
    setState(() => _isSendingReply = true);
    try {
      final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
      final success = await tweetProvider.sendReply(
        tweetId: widget.post.id,
        replyText: replyText,
      );
      if (success) {
        _replyController.clear();
        setState(() => _replyByteCount = 0);
        _showDialog("완료", "리플라이가 성공적으로 전송되었습니다.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tweetProvider.lastErrorMessage ?? "리플라이 전송 실패")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("리플라이 전송 중 오류: ${e.toString()}")),
      );
    } finally {
      setState(() => _isSendingReply = false);
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  Future<void> _onOpen(LinkableElement link) async {
    final uri = Uri.parse(link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(_showOriginal ? "번역문 보기" : "원문 보기"),
              onTap: () {
                setState(() => _showOriginal = !_showOriginal);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("일정 추출"),
              onTap: () {
                Navigator.of(context).pop();
                _onExtractSchedule();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text("취소"),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onExtractSchedule() async {
    final sd = widget.post.includedStartDate;
    final ed = widget.post.includedEndDate;
    if (sd == null && ed == null) {
      _showDialog("알림", "이 포스트에는 일정 정보가 없습니다");
      return;
    }
    // 기존 로직 유지...
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final avatarUrl = post.profileImageUrl?.replaceAll('_normal', '_400x400');
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: avatarUrl == null
                        ? Icon(Icons.person, color: theme.colorScheme.primary)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onUserTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.username,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 2),
                        Text('@${widget.oshiUserId ?? post.uid}',
                            style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withAlpha(153))),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  color: theme.colorScheme.onSurface,
                  onPressed: _showOptions,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 본문
            Linkify(
              text: _showOriginal ? post.message : post.translatedMessage,
              onOpen: _onOpen,
              style: TextStyle(
                  fontSize: 16.5, height: 1.6, color: theme.colorScheme.onSurface),
              linkStyle: TextStyle(
                  color: theme.colorScheme.primary, decoration: TextDecoration.underline),
            ),

            // 이미지 격자
            if (post.imageUrls.isNotEmpty) _buildImageGrid(post.imageUrls),

            // 리플 입력 영역 (onPostPage)
            if (widget.onPostPage) ...[
              const SizedBox(height: 12),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(post.date),
                style: TextStyle(
                    fontSize: 13.5,
                    color: theme.colorScheme.onSurface.withAlpha(153)),
              ),
              const Divider(height: 32),
              TextField(
                controller: _replyController,
                maxLines: null,
                onChanged: _updateLength,
                decoration: InputDecoration(
                  hintText: "리플 입력...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "입력 가능한 문자수: ${280 - _replyByteCount}",
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: (_isLoadingAutoReply || _isSendingReply)
                            ? null
                            : _handleAutoReply,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primary, foregroundColor: onPrimary),
                        child: _isLoadingAutoReply
                            ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(onPrimary),
                          ),
                        )
                            : const Text("자동생성"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: (_isLoadingAutoReply || _isSendingReply)
                            ? null
                            : _handleReplySubmit,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primary, foregroundColor: onPrimary),
                        child: _isSendingReply
                            ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(onPrimary),
                          ),
                        )
                            : const Text("전송"),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}