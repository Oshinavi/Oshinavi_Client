import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mediaproject/data/models/schedule_model.dart';
import 'package:mediaproject/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:mediaproject/presentation/utils/custom_exceptions.dart';

/// EventDetailPage:
/// - 단일 일정의 상세 정보를 보여주며 수정 및 삭제 기능 제공
/// 주요 단계:
/// 1) 화면 상단 SliverAppBar에 수정 버튼과 삭제 버튼 배치
/// 2) 수정 버튼 클릭 시 _EditScheduleDialog 호출 → ScheduleModel 반환 → ViewModel.updateSchedule 호출
///    - 실패 시 커스텀 예외에 따라 AlertDialog로 에러 메시지 표시
/// 3) 삭제 버튼 클릭 시 삭제 확인 다이얼로그 → ViewModel.deleteSchedule 호출
///    - 실패 시 커스텀 예외에 따라 AlertDialog로 에러 메시지 표시
/// 4) SliverList에 일정 정보(카테고리, 관련 트위터 ID, 시작, 종료) 및 설명 표시
class EventDetailPage extends StatelessWidget {
  final ScheduleModel schedule;
  const EventDetailPage({Key? key, required this.schedule}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ScheduleViewModel>();
    final theme = Theme.of(context);
    final fmt = DateFormat('yyyy.MM.dd HH:mm');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 180,
            leading: const BackButton(color: Colors.white),
            actions: [
              // 1) 수정 버튼
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  // _EditScheduleDialog로 수정된 ScheduleModel 반환받음
                  final updatedModel = await showDialog<ScheduleModel?>(
                    context: context,
                    builder: (_) => _EditScheduleDialog(schedule: schedule),
                  );
                  if (updatedModel != null) {
                    try {
                      // 2) ViewModel.updateSchedule 호출
                      await vm.updateSchedule(
                        updatedModel.id,
                        {
                          'title': updatedModel.title,
                          'category': updatedModel.category,
                          'start_at': updatedModel.startAt.toIso8601String(),
                          'end_at': updatedModel.endAt.toIso8601String(),
                          'description': updatedModel.description,
                          'related_twitter_internal_id':
                          updatedModel.relatedTwitterInternalId ?? '',
                        },
                      );
                      Navigator.pop(context, true);
                    }
                    // 3) 예외 처리: 수정 권한 없음, 일정 없음, 네트워크 오류 등
                    on BadRequestException catch (e) {
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('수정 권한이 없습니다'),
                          content: Text(e.message),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
                          ],
                        ),
                      );
                      return;
                    } on NotFoundException catch (e) {
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('수정 실패'),
                          content: Text(e.message),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
                          ],
                        ),
                      );
                      return;
                    } on NetworkException {
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('서버 오류'),
                          content: const Text(
                            '서버와의 통신 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
                          ],
                        ),
                      );
                      return;
                    } catch (e) {
                      // 4) 기타 예외는 SnackBar로 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('수정 실패: $e')),
                      );
                    }
                  }
                },
              ),

              // 5) 삭제 버튼
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('일정 삭제'),
                      content: const Text('정말 이 일정을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    try {
                      await vm.deleteSchedule(schedule.id);
                      Navigator.pop(context, true);
                    } on BadRequestException catch (e) {
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('삭제 권한이 없습니다'),
                          content: Text(e.message),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
                          ],
                        ),
                      );
                      return;
                    } on NotFoundException catch (e) {
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('삭제 실패'),
                          content: Text(e.message),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
                          ],
                        ),
                      );
                      return;
                    } on NetworkException {
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('서버 오류'),
                          content: const Text(
                            '서버와의 통신 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.',
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('확인')),
                          ],
                        ),
                      );
                      return;
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('삭제 실패: $e')),
                      );
                    }
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                schedule.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black45)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColorDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // 일정 상세 정보 카드: 카테고리, 관련 트위터 ID, 시작, 종료
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: Column(children: [
                    _InfoTile(
                      icon: Icons.category,
                      label: '카테고리',
                      value: schedule.category,
                    ),
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.alternate_email,
                      label: '관련 트위터 id(@id)',
                      value: schedule.relatedTwitterInternalId ?? '-',
                    ),
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.schedule,
                      label: '시작',
                      value: fmt.format(schedule.startAt),
                    ),
                    const Divider(height: 1),
                    _InfoTile(
                      icon: Icons.schedule,
                      label: '종료',
                      value: fmt.format(schedule.endAt),
                    ),
                  ]),
                ),

                const SizedBox(height: 24),

                // 설명 블록
                Text('설명', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  schedule.description.isEmpty ? '-' : schedule.description,
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// _InfoTile:
/// - 이벤트 상세 정보 블록에서 아이콘, 라벨, 값 표시용 ListTile 커스텀 위젯
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// _EditScheduleDialog:
/// - AlertDialog 형태로 일정 수정 폼 제공
/// - 제목, 카테고리, 관련 트위터 ID, 설명, 시작/종료 일시 편집 가능
/// - '저장' 버튼 클릭 시 수정된 ScheduleModel 반환
class _EditScheduleDialog extends StatefulWidget {
  final ScheduleModel schedule;
  const _EditScheduleDialog({Key? key, required this.schedule}) : super(key: key);

  @override
  State<_EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<_EditScheduleDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _twtCtrl;
  late DateTime _startAt;
  late DateTime _endAt;
  late String _category;
  final _categories = [
    '일반',
    '방송',
    '라디오',
    '라이브',
    '음반',
    '굿즈',
    '영상',
    '게임'
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    // 초기 컨트롤러 및 날짜/카테고리 설정
    _titleCtrl = TextEditingController(text: s.title);
    _descCtrl = TextEditingController(text: s.description);
    _twtCtrl = TextEditingController(text: s.relatedTwitterInternalId);
    _startAt = s.startAt;
    _endAt = s.endAt;
    _category = s.category;
  }

  /// _dateTimeField:
  /// - 날짜/시간 입력 필드 위젯 반환
  /// - 탭 시 showDatePicker → showTimePicker 호출하여 날짜 및 시간 업데이트
  Widget _dateTimeField(String label, DateTime date, ValueChanged<DateTime> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(DateFormat('yyyy.MM.dd HH:mm').format(date)),
      onTap: () async {
        // 날짜 선택 다이얼로그
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (d == null) return;
        // 시간 선택 다이얼로그
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(date),
        );
        if (t == null) return;
        onChanged(DateTime(d.year, d.month, d.day, t.hour, t.minute));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('일정 수정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 입력 필드
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 8),

            // 카테고리 드롭다운
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: '카테고리'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 8),

            // 관련 트위터 ID 입력 필드
            TextField(
              controller: _twtCtrl,
              decoration: const InputDecoration(labelText: '관련 트위터 id(@id)'),
            ),
            const SizedBox(height: 8),

            // 설명 입력 필드
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: '설명'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // 시작 일시 선택 필드
            _dateTimeField('시작 일시', _startAt, (d) => setState(() => _startAt = d)),
            // 종료 일시 선택 필드
            _dateTimeField('종료 일시', _endAt, (d) => setState(() => _endAt = d)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        TextButton(
          onPressed: () {
            // 수정된 ScheduleModel 생성 후 반환
            final edited = widget.schedule.copyWith(
              title: _titleCtrl.text,
              category: _category,
              startAt: _startAt,
              endAt: _endAt,
              description: _descCtrl.text,
              relatedTwitterInternalId: _twtCtrl.text.isEmpty ? null : _twtCtrl.text,
            );
            Navigator.pop(context, edited);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}