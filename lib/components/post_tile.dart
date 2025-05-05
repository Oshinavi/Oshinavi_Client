import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:characters/characters.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../services/oshi_provider.dart';
import '../services/tweet_provider.dart';
import '../viewmodels/schedule_view_model.dart';
import '../models/schedule.dart';

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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  /// 일정 추출 버튼을 눌렀을 때 호출됩니다.
  Future<void> _onExtractSchedule() async {
    final sd = widget.post.includedStartDate;
    final ed = widget.post.includedEndDate;

    // 일정 정보가 없으면 안내
    if (sd == null && ed == null) {
      _showDialog("알림", "이 포스트에는 일정 정보가 없습니다");
      return;
    }

    // 초기값 설정
    DateTime startAt = sd ?? ed!.subtract(const Duration(hours: 1));
    DateTime endAt   = ed ?? sd!.add(const Duration(hours: 1));
    final titleCtrl = TextEditingController(text: '');
    final descCtrl  = TextEditingController(text: '');
    final twtCtrl   = TextEditingController(text: widget.post.uid);

    const categories = [
      '일반', '방송', '라디오', '라이브',
      '음반', '굿즈', '영상', '게임',
    ];
    String selectedCategory = widget.post.tweetAbout != null && categories.contains(widget.post.tweetAbout)
        ? widget.post.tweetAbout!
        : categories.first;

    // 다이얼로그 띄우기
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          Widget _buildDateTimeField(String label, DateTime value, VoidCallback onTap) {
            return TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: label,
                hintText: DateFormat('yyyy.MM.dd HH:mm').format(value),
              ),
              controller: TextEditingController(text: DateFormat('yyyy.MM.dd HH:mm').format(value)),
              onTap: onTap,
            );
          }

          return AlertDialog(
            title: const Text('일정 등록'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: '카테고리'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: twtCtrl,
                  decoration: const InputDecoration(labelText: '관련 트위터 스크린네임'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: '설명'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildDateTimeField('시작 일시', startAt, () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: startAt,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (d == null) return;
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.fromDateTime(startAt),
                  );
                  if (t == null) return;
                  setState(() {
                    startAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                    if (endAt.isBefore(startAt)) {
                      endAt = startAt.add(const Duration(hours: 1));
                    }
                  });
                }),
                const SizedBox(height: 8),
                _buildDateTimeField('종료 일시', endAt, () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: endAt,
                    firstDate: startAt,
                    lastDate: DateTime(2100),
                  );
                  if (d == null) return;
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.fromDateTime(endAt),
                  );
                  if (t == null) return;
                  setState(() {
                    endAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                  });
                }),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
              TextButton(
                onPressed: () {
                  if (titleCtrl.text.isEmpty) return;
                  Navigator.pop(ctx, true);
                },
                child: const Text('등록'),
              ),
            ],
          );
        });
      },
    );
    if (ok != true) return;

    // 일정 추가
    final vm = context.read<ScheduleViewModel>();
    final newSched = Schedule(
      id: 0,
      title: titleCtrl.text,
      category: selectedCategory,
      startAt: startAt,
      endAt: endAt,
      description: descCtrl.text,
      relatedTwitterInternalId: twtCtrl.text,
      createdByUserId: 0,
    );
    try {
      await vm.addSchedule(newSched);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정이 등록되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 등록 실패: $e')),
      );
    }
  }

  /// 옵션 시트에 “일정 추출” 항목을 추가하고, 눌렀을 때 _onExtractSchedule 호출
  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
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
            // 사용자 정보 + 옵션 버튼
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    child: avatarUrl == null
                        ? Icon(Icons.person, color: theme.colorScheme.primary)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onUserTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.username, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
                        const SizedBox(height: 2),
                        Text('@${widget.oshiUserId ?? post.uid}', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
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

            // 번역된 텍스트
            Text(post.translatedMessage, style: TextStyle(fontSize: 16.5, height: 1.6, color: theme.colorScheme.onSurface)),

            // 상세 페이지 전용 UI
            if (widget.onPostPage) ...[
              const SizedBox(height: 12),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(post.date),
                style: TextStyle(fontSize: 13.5, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const Divider(height: 32),
              // 기존 리플라이 UI
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
                  Row(children: [
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
                  ]),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}