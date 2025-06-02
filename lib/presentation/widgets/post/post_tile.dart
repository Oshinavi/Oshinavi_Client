import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:characters/Characters.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/post.dart';
import '../../../domain/entities/reply.dart';
import '../../viewmodels/tweet_viewmodel.dart';
import '../../viewmodels/schedule_viewmodel.dart';
import '../../../domain/entities/schedule.dart';
import '../../widgets/common/loading_indicator.dart';

// ▶ ScheduleApi 예외들을 불러옴
import '../../../data/repositories/schedule_repository_impl.dart'
    show ScheduleBadRequestException,
    ScheduleNotFoundException,
    ScheduleConflictException,
    ScheduleServerException;
import '../common/loading_circle.dart';

/// PostTile:
/// - 한 개의 포스트(트윗) 내용을 카드 형태로 표시
/// - 사용자의 아바타, 사용자명, 스크린네임, 포스트 본문, 이미지, 일정 추출 메뉴, 리플라이 입력 기능 제공
///
/// 파라미터:
/// - post: 표시할 Post 엔티티
/// - onUserTap: 프로필 클릭 시 콜백
/// - onPostTap: 포스트 전체 클릭 시 콜백 (상세 페이지 이동 등)
/// - onReplySent: 새로운 리플라이 작성 시, 상위 위젯에 알려줄 콜백
/// - oshiTweetId: 자동 일정 추출 시 기본으로 제안할 트위터 ID
/// - onPostPage: 이 위젯이 포스트 상세 페이지에 쓰이는지 여부
class PostTile extends StatefulWidget {
  final Post post;
  final VoidCallback? onUserTap;
  final VoidCallback? onPostTap;
  final void Function(Reply)? onReplySent;
  final String? oshiTweetId; // 자동 일정 추출 시 사용할 “오시” 트위터 ID
  final bool onPostPage;      // true인 경우 리플라이 입력칸 표시

  const PostTile({
    Key? key,
    required this.post,
    this.onUserTap,
    this.onPostTap,
    this.onReplySent,
    this.oshiTweetId,
    this.onPostPage = false,
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

  /// _updateLength:
  /// - 입력된 텍스트의 바이트 수를 계산
  /// - ASCII 문자는 1바이트, 기타(한글 등)는 2바이트로 가정
  void _updateLength(String text) {
    int count = 0;
    for (final ch in text.characters) {
      count += RegExp(r'^[\x00-\x7F]$').hasMatch(ch) ? 1 : 2;
    }
    setState(() => _replyByteCount = count);
  }

  /// _handleAutoReply:
  /// - TweetViewModel.generateAutoReply 호출하여 자동 리플라이 생성
  /// - 생성된 텍스트를 하나씩 _replyController에 타이핑 효과와 함께 입력
  Future<void> _handleAutoReply() async {
    setState(() => _isLoadingAutoReply = true);
    final tweetVm = context.read<TweetViewModel>();

    // 1) 기존 리플라이 목록에서 컨텍스트 수집 (예시: 두 번째 리플라이 제외)
    final contexts = <String>[];
    final allReplies = tweetVm.replies;
    for (var i = 0; i < allReplies.length; i++) {
      if (i == 1) continue; // 예시 로직: 두 번째 리플라이만 생략
      contexts.add(allReplies[i].text);
    }

    // 2) 자동 생성된 리플라이 텍스트 요청
    final replyText = await tweetVm.generateAutoReply(
      tweetId: widget.post.id,
      tweetText: widget.post.message,
      contexts: contexts,
    );

    if (!mounted) return;
    if (replyText != null) {
      // 3) 생성된 텍스트를 타이핑 애니메이션으로 입력
      _replyController.clear();
      for (final ch in replyText.characters) {
        await Future.delayed(const Duration(milliseconds: 30));
        _replyController.text += ch;
        _replyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _replyController.text.length),
        );
        _updateLength(_replyController.text);
      }
    }
    setState(() => _isLoadingAutoReply = false);
  }

  /// _handleReplySubmit:
  /// - 입력된 리플라이 텍스트가 280바이트 이하인지 검증
  /// - TweetViewModel.sendReply 호출하여 서버로 리플라이 전송
  /// - 전송 성공 시 상위 콜백 onReplySent 호출, 에러 시 스낵바로 안내
  Future<void> _handleReplySubmit() async {
    final vm = context.read<TweetViewModel>();
    final replyText = _replyController.text.trim();

    if (_replyByteCount > 280) {
      _showSimpleDialog("에러", "글자수가 너무 많습니다 (최대 280자)");
      return;
    }

    setState(() => _isSendingReply = true);
    try {
      final newReply = await vm.sendReply(widget.post.id, replyText);
      _replyController.clear();
      _updateLength('');
      widget.onReplySent?.call(newReply);
      _showSimpleDialog("완료", "리플라이가 성공적으로 전송되었습니다.");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("리플라이 전송 중 오류: ${e.toString()}")),
      );
    } finally {
      setState(() => _isSendingReply = false);
    }
  }

  /// _showSimpleDialog:
  /// - 제목과 내용을 받아 간단한 AlertDialog를 표시
  void _showSimpleDialog(String title, String content) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// _onOpen:
  /// - Linkify 패키지의 링크 클릭 시 실행됨
  /// - canLaunchUrl로 외부 브라우저에서 링크 열기
  Future<void> _onOpen(LinkableElement link) async {
    final uri = Uri.parse(link.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// _showExtractScheduleOptions:
  /// - “…” 버튼을 눌렀을 때 보여줄 일정 추출 옵션 BottomSheet 표시
  /// - 원문/번역 전환, 일정 추출, 취소 메뉴 제공
  void _showExtractScheduleOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(_showOriginal ? "번역문 보기" : "원문 보기"),
              onTap: () {
                // 1) _showOriginal 플래그 토글
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

  /// _onExtractSchedule:
  /// - 로딩 다이얼로그 표시 후 TweetViewModel.fetchMetadata 호출하여 메타데이터(일정 정보) 가져오기
  /// - 메타데이터 유무에 따라 다이얼로그 또는 일괄 처리
  /// - 날짜 문자열을 파싱해 시작/종료 시간 결정
  /// - InputAlertDialog 스타일의 일정 등록 다이얼로그 표시
  /// - ManageScheduleUseCase를 통해 실제 일정 추가 (예외 처리 포함)
  Future<void> _onExtractSchedule() async {
    // 1) 로딩 다이얼로그 표시
    showLoadingCircle(context);

    try {
      final tweetVm = context.read<TweetViewModel>();
      final metadata = await tweetVm.fetchMetadata(widget.post.id);

      final category = metadata['category'] as String?;
      final rawStart = metadata['start'] as String?;
      final rawEnd = metadata['end'] as String?;
      final titleMeta = metadata['schedule_title'] as String?;
      final descMeta = metadata['schedule_description'] as String?;

      String? sanitize(String? s) {
        if (s == null) return null;
        final t = s.trim().toLowerCase();
        return (t == 'none') ? null : s.trim();
      }

      final startStr = sanitize(rawStart);
      final endStr = sanitize(rawEnd);

      // 2) 일정 정보가 없으면 로딩 다이얼로그 닫고 안내
      if (category == '일반' || (startStr == null && endStr == null)) {
        hideLoadingCircle(context);
        _showSimpleDialog("알림", "이 포스트에는 일정 정보가 없습니다");
        return;
      }

      // 3) 날짜 문자열 파싱
      DateTime parseDate(String s) {
        final normalized = s.replaceAll('.', '-');
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(normalized);
      }

      DateTime startAt = startStr != null
          ? parseDate(startStr)
          : parseDate(endStr!).subtract(const Duration(hours: 1));
      DateTime endAt = endStr != null
          ? parseDate(endStr)
          : parseDate(startStr!).add(const Duration(hours: 1));

      // 4) BottomSheet 입력 다이얼로그용 컨트롤러 및 초기값 설정
      final titleCtrl = TextEditingController(text: titleMeta ?? "");
      final descCtrl = TextEditingController(text: descMeta ?? "");
      final twtCtrl = TextEditingController(text: widget.oshiTweetId ?? "");

      const categories = [
        '일반',
        '방송',
        '라디오',
        '라이브',
        '음반',
        '굿즈',
        '영상',
        '게임'
      ];
      String selectedCategory =
      categories.contains(category) ? category! : categories.first;

      // 5) 사용자에게 일정 제목, 카테고리, 오시 TweetId, 설명, 시작/종료 시간 입력받기
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          DateTime tempStart = startAt;
          DateTime tempEnd = endAt;

          Widget _dateTimeField(String label, DateTime value, VoidCallback onTap) {
            return GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                    text: DateFormat('yyyy.MM.dd HH:mm').format(value),
                  ),
                  decoration: InputDecoration(labelText: label),
                ),
              ),
            );
          }

          return StatefulBuilder(builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('일정 등록'),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // 제목 입력
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: '제목'),
                  ),
                  const SizedBox(height: 8),
                  // 카테고리 선택
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: '카테고리'),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v ?? categories.first),
                  ),
                  const SizedBox(height: 8),
                  // 오시 Tweet ID 입력
                  TextField(
                    controller: twtCtrl,
                    decoration: const InputDecoration(labelText: '오시 트위터 ID(@id)'),
                  ),
                  const SizedBox(height: 8),
                  // 설명 입력
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: '설명'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  // 시작 일시 필드
                  _dateTimeField('시작 일시', tempStart, () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: tempStart,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(tempStart),
                    );
                    if (t == null) return;
                    setState(() {
                      tempStart = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                      if (tempEnd.isBefore(tempStart)) {
                        tempEnd = tempStart.add(const Duration(hours: 1));
                      }
                    });
                  }),
                  const SizedBox(height: 8),
                  // 종료 일시 필드
                  _dateTimeField('종료 일시', tempEnd, () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: tempEnd,
                      firstDate: tempStart,
                      lastDate: DateTime(2100),
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.fromDateTime(tempEnd),
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

      // 6) 로딩 다이얼로그 닫기
      hideLoadingCircle(context);

      if (ok != true) {
        // 사용자가 “취소”를 눌렀을 때 처리 중단
        return;
      }

      final scheduleVM = context.read<ScheduleViewModel>();

      // ------------------------------------
      // ① 일정 추가 시도 (예외 발생 가능)
      // ------------------------------------
      await scheduleVM.addSchedule(
        Schedule(
          id: 0,
          title: titleCtrl.text,
          category: selectedCategory,
          startAt: startAt,
          endAt: endAt,
          description: descCtrl.text,
          relatedTwitterInternalId: twtCtrl.text,
          createdByUserId: 0,
        ),
      );

      // ------------------------------------
      // ② 성공 시 스낵바만 띄움
      // ------------------------------------
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 일정이 등록되었습니다.')),
      );
    }
    // ▷ 트위터 스크린네임을 찾을 수 없는 경우 (404) → ScheduleNotFoundException
    on ScheduleNotFoundException catch (_) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('일정 등록 실패'),
          content: const Text(
            '유효하지 않은 트위터 스크린네임입니다.\n다시 확인해주세요.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
    // ▷ 잘못된 입력(400 Bad Request) → ScheduleBadRequestException
    on ScheduleBadRequestException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('잘못된 입력'),
          content: Text(
            '입력이 잘못되었습니다:\n${e.message}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
    // ▷ 충돌이 발생했거나 권한 없음 등(409) → ScheduleConflictException
    on ScheduleConflictException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('충돌 오류'),
          content: Text(e.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
    // ▷ 서버 내부 오류(500) → ScheduleServerException
    on ScheduleServerException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('서버 오류'),
          content: Text(
            '서버와의 통신 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.\n\n(오류: ${e.message})',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
    // ▷ 기타: 예측하지 못한 예외
    catch (e) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('알 수 없는 오류'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    // 오시 프로필 사진 URL에서 “_normal” suffix를 “_400x400”으로 바꿔 고해상도 사용
    final avatarUrl = post.profileImageUrl?.replaceAll('_normal', '_400x400');

    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return GestureDetector(
      onTap: widget.onPostTap, // 포스트 클릭 시 콜백 호출
      child: Container(
        margin: const EdgeInsets.only(top: 6, bottom: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 사용자 정보 + 옵션 버튼 ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.onUserTap,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage:
                    (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                    backgroundColor:
                    theme.colorScheme.surfaceContainerHighest,
                    child: (avatarUrl == null || avatarUrl.isEmpty)
                        ? Icon(Icons.person,
                        color: theme.colorScheme.primary)
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
                          '@${post.uid}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface
                                .withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  color: theme.colorScheme.onSurface,
                  onPressed: _showExtractScheduleOptions,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- 본문 / 번역 토글 ---
            Linkify(
              text: _showOriginal
                  ? post.message
                  : post.translatedMessage,
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

            // --- 이미지 격자 (최대 4개) ---
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: post.imageUrls.length.clamp(1, 4),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                  post.imageUrls.length == 1 ? 1 : 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (ctx, i) {
                  final imgUrl = post.imageUrls[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/image_preview',
                        arguments: {
                          'imageUrl': imgUrl,
                          'tag': '${post.id}_$i',
                        },
                      );
                    },
                    child: Hero(
                      tag: '${post.id}_$i',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, prog) =>
                          prog == null
                              ? child
                              : const LoadingIndicator(),
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            // --- 포스트 상세 페이지 모드: 리플라이 입력 UI ---
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "입력 가능한 글자수: ${280 - _replyByteCount}",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                        _isLoadingAutoReply || _isSendingReply
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
                        onPressed:
                        _isLoadingAutoReply || _isSendingReply
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