import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:characters/characters.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/reply.dart';
import 'loading_circle.dart';

import '../models/post.dart';
import '../services/oshi_provider.dart';
import '../services/tweet_provider.dart';
import '../viewmodels/schedule_view_model.dart';
import '../models/schedule.dart';
import '../pages/image_preview_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;
  final void Function(Reply)? onReplySent;
  final OshiProvider oshiProvider;
  final bool onPostPage;
  final String? oshiUserId;

  const PostTile({
    Key? key,
    required this.post,
    this.onUserTap,
    this.onPostTap,
    this.onReplySent,
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

  /// ① 이미지 URL 리스트를 받아 1~4개 격자로 배치해 주는 헬퍼
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
      if (!mounted) return;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("자동 생성 실패: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAutoReply = false);
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
      final newReply = await tweetProvider.sendReply(
        tweetId: widget.post.id,
        replyText: replyText,
      );
      if (!mounted) return;

      // clear input
      _replyController.clear();
      setState(() => _replyByteCount = 0);
      _showDialog("완료", "리플라이가 성공적으로 전송되었습니다.");

      // notify parent
      widget.onReplySent?.call(newReply);    // ← NEW

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("리플라이 전송 중 오류: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingReply = false);
    }
  }

  void _showDialog(String title, String content) {
    if (!mounted) return;
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

  Future<void> _onExtractSchedule() async {
    // ① 로딩 서클 표시
    showLoadingCircle(context);

    try {
      // ② 메타데이터 가져오기
      final tweetProvider = Provider.of<TweetProvider>(context, listen: false);
      final meta = await tweetProvider.fetchTweetMetadata(widget.post.id);

      final category = meta['category'] as String?;
      final rawStart = meta['start'] as String?;
      final rawEnd   = meta['end']   as String?;
      final titleMeta = meta['schedule_title'] as String?;
      final descMeta = meta['schedule_description'] as String?;

      String? sanitize(String? s) {
        if (s == null) return null;
        final t = s.trim().toLowerCase();
        return (t == 'none') ? null : s.trim();
      }
      final startStr = sanitize(rawStart);
      final endStr   = sanitize(rawEnd);

      // ③ 일정 정보가 없거나, 분류가 "일반" 이면 안내 다이얼로그 후 종료
      if (category == '일반' || (startStr == null && endStr == null)) {
        hideLoadingCircle(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showDialog("알림", "이 포스트에는 일정 정보가 없습니다");
        });
        return;
      }

      // ④ 날짜 파싱 유틸
      DateTime parseDate(String s) {
        final normalized = s.replaceAll('.', '-');
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(normalized);
      }

      // ⑤ start/end 결정 (하나만 있으면 ±1시간)
      DateTime startAt = startStr != null
          ? parseDate(startStr)
          : parseDate(endStr!).subtract(const Duration(hours: 1));
      DateTime endAt = endStr != null
          ? parseDate(endStr)
          : parseDate(startStr!).add(const Duration(hours: 1));

      // ⑥ 다이얼로그용 컨트롤러 & 초기값
      final titleCtrl = TextEditingController(text: titleMeta ?? "");
      final descCtrl  = TextEditingController(text: descMeta ?? "");
      final twtCtrl   = TextEditingController(text: widget.post.uid);
      const categories = ['일반','방송','라디오','라이브','음반','굿즈','영상','게임'];
      String selectedCategory = categories.contains(category) ? category! : categories.first;

      // ⑦ 사용자에게 일정 정보 입력받기
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          DateTime tempStart = startAt;
          DateTime tempEnd   = endAt;

          Widget _buildDateTimeField(String label, DateTime value, VoidCallback onTap) {
            return TextField(
              readOnly: true,
              controller: TextEditingController(
                text: DateFormat('yyyy.MM.dd HH:mm').format(value),
              ),
              decoration: InputDecoration(labelText: label),
              onTap: onTap,
            );
          }

          return StatefulBuilder(builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('일정 등록'),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: '제목')),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: '카테고리'),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => selectedCategory = v ?? categories.first),
                  ),
                  const SizedBox(height: 8),
                  TextField(controller: twtCtrl, decoration: const InputDecoration(labelText: '오시 트위터 ID(@id)')),
                  const SizedBox(height: 8),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: '설명'), maxLines: 2),
                  const SizedBox(height: 12),
                  _buildDateTimeField('시작 일시', tempStart, () async {
                    final d = await showDatePicker(
                      context: ctx, initialDate: tempStart, firstDate: DateTime(2000), lastDate: DateTime(2100),
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: ctx, initialTime: TimeOfDay.fromDateTime(tempStart),
                    );
                    if (t == null) return;
                    setState(() {
                      tempStart = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                      if (tempEnd.isBefore(tempStart)) tempEnd = tempStart.add(const Duration(hours: 1));
                    });
                  }),
                  const SizedBox(height: 8),
                  _buildDateTimeField('종료 일시', tempEnd, () async {
                    final d = await showDatePicker(
                      context: ctx, initialDate: tempEnd, firstDate: tempStart, lastDate: DateTime(2100),
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: ctx, initialTime: TimeOfDay.fromDateTime(tempEnd),
                    );
                    if (t == null) return;
                    setState(() {
                      tempEnd = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                    });
                  }),
                ]),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('등록')),
              ],
            );
          });
        },
      );
      if (ok != true) return;

      // ⑧ ViewModel 에 저장
      final vm = context.read<ScheduleViewModel>();
      await vm.addSchedule(Schedule(
        id: 0,
        title: titleCtrl.text,
        category: selectedCategory,
        startAt: startAt,
        endAt: endAt,
        description: descCtrl.text,
        relatedTwitterInternalId: twtCtrl.text,
        createdByUserId: 0,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정이 등록되었습니다.')),
      );

    } catch (e) {
      // ⑨ 에러 시 스낵바
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("일정 정보 로드 실패: ${e.toString()}")),
      );
    } finally {
      // ⑩ 항상 로딩 서클 닫기
      hideLoadingCircle(context);
    }
  }

  void _showOptions() {
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
        margin: const EdgeInsets.only(top:6, bottom:6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 + 옵션
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
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
                        Text(
                          post.username,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${widget.oshiUserId ?? post.uid}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
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

            // 본문 / 번역
            Linkify(
              text: _showOriginal ? post.message : post.translatedMessage,
              onOpen: _onOpen,
              style: TextStyle(
                fontSize: 16.5,
                height: 1.6,
                color: theme.colorScheme.onSurface,
              ),
              linkStyle: TextStyle(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),

            // ② 이미지가 있으면 격자 형태로 표시
            if (post.imageUrls.isNotEmpty) _buildImageGrid(post.imageUrls),

            // 리플 입력 영역 (onPostPage일 때만)
            if (widget.onPostPage) ...[
              const SizedBox(height: 12),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(post.date),
                style: TextStyle(
                  fontSize: 13.5,
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "입력 가능한 문자수: ${280 - _replyByteCount}",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoadingAutoReply || _isSendingReply
                            ? null
                            : _handleAutoReply,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                        ),
                        child: _isLoadingAutoReply
                            ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation(onPrimary),
                          ),
                        )
                            : const Text("자동생성"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoadingAutoReply || _isSendingReply
                            ? null
                            : _handleReplySubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                        ),
                        child: _isSendingReply
                            ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation(onPrimary),
                          ),
                        )
                            : const Text("전송"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}