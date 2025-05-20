// lib/pages/event_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/schedule.dart';
import '../viewmodels/schedule_view_model.dart';
import '../utils/api_exception.dart';

class EventDetailPage extends StatelessWidget {
  final Schedule schedule;
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
            leading: BackButton(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final updated = await showDialog<Schedule?>(
                    context: context,
                    builder: (_) => _EditScheduleDialog(schedule: schedule),
                  );
                  if (updated != null) {
                    try {
                      await vm.updateSchedule(updated.id, {
                        'title': updated.title,
                        'category': updated.category,
                        'start_at': updated.startAt.toIso8601String(),
                        'end_at': updated.endAt.toIso8601String(),
                        'description': updated.description,
                        'related_twitter_screen_name': updated.relatedTwitterInternalId,
                      });
                      Navigator.pop(context, true);
                    } on ApiException catch (e) {
                      final title = e.statusCode == 400
                          ? '수정 권한이 없습니다'
                          : '수정 실패';
                      final content = e.statusCode == 400
                          ? '이 일정을 수정할 권한이 없습니다.'
                          : e.message;
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(title),
                          content: Text(content),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                      return;
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('수정 실패: $e')));
                    }
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('일정 삭제'),
                      content: const Text('정말 이 일정을 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('취소'),
                        ),
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
                    } on ApiException catch (e) {
                      final title = e.statusCode == 400
                          ? '삭제 권한이 없습니다'
                          : '삭제 실패';
                      final content = e.statusCode == 400
                          ? '이 일정을 삭제할 권한이 없습니다.'
                          : e.message;
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(title),
                          content: Text(content),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                      );
                      return;
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
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

                Text('설명', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(schedule.description ?? '-', style: theme.textTheme.bodyMedium),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

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

class _EditScheduleDialog extends StatefulWidget {
  final Schedule schedule;
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
  String _category = '';
  final _categories = ['일반','방송','라디오','라이브','음반','굿즈','영상','게임'];

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _titleCtrl = TextEditingController(text: s.title);
    _descCtrl  = TextEditingController(text: s.description);
    _twtCtrl   = TextEditingController(text: s.relatedTwitterInternalId);
    _startAt   = s.startAt;
    _endAt     = s.endAt;
    _category  = s.category;
  }

  Widget _dateTimeField(String label, DateTime date, ValueChanged<DateTime> onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(DateFormat('yyyy.MM.dd HH:mm').format(date)),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (d == null) return;
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
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: '제목')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: '카테고리'),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 8),
          TextField(controller: _twtCtrl, decoration: const InputDecoration(labelText: '관련 트위터 id(@id)')),
          const SizedBox(height: 8),
          TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: '설명'), maxLines: 2),
          const SizedBox(height: 12),
          _dateTimeField('시작 일시', _startAt, (d) => setState(() => _startAt = d)),
          _dateTimeField('종료 일시', _endAt, (d) => setState(() => _endAt = d)),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        TextButton(
          onPressed: () {
            final edited = widget.schedule.copyWith(
              title: _titleCtrl.text,
              category: _category,
              startAt: _startAt,
              endAt: _endAt,
              description: _descCtrl.text,
              relatedTwitterInternalId: _twtCtrl.text,
            );
            Navigator.pop(context, edited);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}