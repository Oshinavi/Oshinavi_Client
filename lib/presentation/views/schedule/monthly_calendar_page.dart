import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_calendar/custom_calendar.dart';
import 'package:custom_calendar/src/utils/extension.dart';
import 'package:intl/intl.dart';

import 'package:mediaproject/data/models/schedule_model.dart';
import 'package:mediaproject/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:mediaproject/core/utils/color_generator.dart';
import 'event_detail_page.dart';
import '../../../data/repositories/schedule_repository_impl.dart'
    show
    ScheduleBadRequestException,
    ScheduleNotFoundException,
    ScheduleConflictException,
    ScheduleServerException;

/// MonthlyCalendarPage:
/// - 달력 인터페이스로 한 달 단위 이벤트(일정) 목록을 표시하고 '+' 버튼을 눌러 새 일정 추가 다이얼로그 표시
/// - 이벤트 클릭 시 EventDetailPage로 이동
/// 주요 단계:
/// 1) initState에서 _colorReady=true 후 ScheduleViewModel.loadSchedules 호출
/// 2) _goPrev/_goNext: 달력 월 이동
/// 3) _onAdd: 새 일정 추가 다이얼로그 표시 → 입력값 검증 → ScheduleModel 생성 → ViewModel.addSchedule 호출
///    - 예외에 따라 AlertDialog로 에러 메시지 표시
/// 4) build: 달력 위젯(CustomEventsMonths) 생성, 이벤트 색상 지정 후 달력에 추가
class MonthlyCalendarPage extends StatefulWidget {
  const MonthlyCalendarPage({Key? key}) : super(key: key);
  static const routeName = '/monthly_calendar';

  @override
  State<MonthlyCalendarPage> createState() => _MonthlyCalendarPageState();
}

class _MonthlyCalendarPageState extends State<MonthlyCalendarPage> {
  final EventsController _controller = EventsController();
  final _calendarKey = GlobalKey<CustomEventsMonthsState>();
  final ColorGenerator _colorGenerator = ColorGenerator();
  DateTime _currentMonth = DateTime.now();
  bool _colorReady = false; // 달력이 색상을 그릴 준비가 되었는지 여부

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1) 달력 색상 준비 완료
      setState(() => _colorReady = true);
      // 2) ViewModel.loadSchedules 호출하여 일정 로드
      await context.read<ScheduleViewModel>().loadSchedules();
    });
  }

  /// _goPrev: 이전 달로 이동
  void _goPrev() {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1);
    _calendarKey.currentState?.jumpToDateCustom(prev);
    setState(() => _currentMonth = prev);
  }

  /// _goNext: 다음 달로 이동
  void _goNext() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    _calendarKey.currentState?.jumpToDateCustom(next);
    setState(() => _currentMonth = next);
  }

  /// _buildDateTimeField:
  /// - 읽기 전용 텍스트필드로 날짜/시간 표시
  /// - 탭 시 onTap 콜백 호출
  Widget _buildDateTimeField(String label, DateTime? value, VoidCallback onTap) {
    final text = value == null ? '' : DateFormat('yyyy.MM.dd HH:mm').format(value);
    return TextField(
      readOnly: true,
      decoration: InputDecoration(labelText: label, hintText: '선택'),
      controller: TextEditingController(text: text),
      onTap: onTap,
    );
  }

  /// _onAdd:
  /// - 새 일정 추가 다이얼로그 표시
  /// - 입력값 검증 후 ScheduleModel 생성 → ViewModel.addSchedule 호출
  /// - 성공 시 SnackBar, 예외 시 AlertDialog로 메시지 표시
  Future<void> _onAdd() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final twtCtrl = TextEditingController();
    DateTime? startAt;
    DateTime? endAt;

    const categories = [
      '일반',
      '방송',
      '라디오',
      '라이브',
      '음반',
      '굿즈',
      '영상',
      '게임',
    ];
    String selectedCategory = categories.first;

    // 다이얼로그로 일정 입력 받아 ok 플래그 반환
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('새 이벤트 추가'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목 입력
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: '제목'),
                  ),
                  const SizedBox(height: 8),
                  // 카테고리 선택 드롭다운
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: '카테고리'),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 8),
                  // 관련 트위터 ID 입력
                  TextField(
                    controller: twtCtrl,
                    decoration: const InputDecoration(labelText: '관련 오시 id(@id)'),
                  ),
                  const SizedBox(height: 8),
                  // 설명 입력
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: '설명'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  // 시작 일시 입력 필드
                  _buildDateTimeField('시작 일시', startAt, () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t == null) return;
                    setState(() {
                      startAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                      // endAt가 null이면 시작 시간 + 1시간
                      endAt ??= startAt!.add(const Duration(hours: 1));
                    });
                  }),
                  const SizedBox(height: 8),
                  // 종료 일시 입력 필드
                  _buildDateTimeField('종료 일시', endAt, () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: startAt ?? DateTime.now(),
                      firstDate: startAt ?? DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (d == null) return;
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t == null) return;
                    setState(() {
                      endAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                    });
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
              TextButton(
                onPressed: () {
                  final isValid = titleCtrl.text.isNotEmpty && startAt != null && endAt != null;
                  Navigator.pop(ctx, isValid);
                },
                child: const Text('추가'),
              ),
            ],
          );
        });
      },
    );

    if (ok != true) return;

    // 3) ScheduleModel 객체 생성 (id = 0, 서버가 실제 ID 할당)
    final newSchedModel = ScheduleModel(
      id: 0,
      title: titleCtrl.text,
      category: selectedCategory,
      startAt: startAt!,
      endAt: endAt!,
      description: descCtrl.text,
      relatedTwitterInternalId: twtCtrl.text.isEmpty ? null : twtCtrl.text,
      createdByUserId: 0, // 추후 실제 로그인된 유저 ID로 대체 필요
    );

    // ScheduleModel → 도메인 엔터티 변환
    final newSchedEntity = newSchedModel.toEntity();

    final scheduleVM = context.read<ScheduleViewModel>();

    try {
      // 4) ViewModel.addSchedule 호출 → 예외 발생 가능
      await scheduleVM.addSchedule(newSchedEntity);

      // 5) 성공 시 SnackBar만 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일정이 등록되었습니다.')),
      );
    }
    // 6) 예외 처리: ScheduleNotFoundException, ScheduleBadRequestException, ScheduleConflictException, ScheduleServerException
    on ScheduleNotFoundException catch (_) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('일정 등록 실패'),
          content: const Text(
            '유효하지 않은 트위터 스크린네임입니다.\n다시 확인해주세요.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인')),
          ],
        ),
      );
    } on ScheduleBadRequestException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('잘못된 입력'),
          content: Text('입력이 잘못되었습니다:\n${e.message}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인')),
          ],
        ),
      );
    } on ScheduleConflictException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('충돌 오류'),
          content: Text(e.message),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인')),
          ],
        ),
      );
    } on ScheduleServerException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('서버 오류'),
          content: Text(
            '서버와의 통신 중 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.\n\n(오류: ${e.message})',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인')),
          ],
        ),
      );
    } catch (e) {
      // 7) 기타 예외 처리
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('알 수 없는 오류'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthLabel = DateFormat('yyyy년 M월').format(_currentMonth);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: _goPrev),
            Text(
              monthLabel,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: _goNext),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
      // 로딩 준비가 안되면 로딩 인디케이터
      body: !_colorReady
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ScheduleViewModel>(
        builder: (ctx, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 도메인 Schedule 리스트 → ScheduleModel 리스트 변환
          final List<ScheduleModel> modelList =
          vm.schedules.map((d) => ScheduleModel.fromEntity(d)).toList();

          // ScheduleModel 리스트를 달력 이벤트로 변환
          final events = modelList.map((model) {
            final key = '${model.relatedTwitterInternalId}_${model.id}';
            final color = _colorGenerator.getColor(key);
            return Event(
              startTime: model.startAt,
              endTime: model.endAt,
              title: model.title,
              description: model.description,
              color: color,
              data: model, // 클릭 시 EventDetailPage로 전달
            );
          }).toList();

          // 달력 컨트롤러에 이벤트 반영
          _controller.updateCalendarData((cal) {
            cal.clearAll();
            cal.addEvents(events);
          });

          // CustomEventsMonths 달력 위젯 반환
          return CustomEventsMonths(
            key: _calendarKey,
            controller: _controller,
            automaticAdjustScrollToStartOfMonth: true,
            onMonthChange: (m) => setState(() => _currentMonth = m),
            weekParam: WeekParam(
              startOfWeekDay: 7,
              headerDayBuilder: (dow) {
                const labels = {
                  1: '월',
                  2: '화',
                  3: '수',
                  4: '목',
                  5: '금',
                  6: '토',
                  7: '일'
                };
                final color = dow == 7
                    ? Colors.redAccent
                    : dow == 6
                    ? Colors.blueAccent
                    : (isDark ? Colors.white : Colors.black);
                return Center(
                  child: Text(
                    labels[dow]!,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            daysParam: DaysParam(
              dayHeaderBuilder: (date) {
                final isInCurrentMonth = date.month == _currentMonth.month;
                final isToday = DateUtils.isSameDay(date, DateTime.now());
                return DefaultMonthDayHeader(
                  text: date.day.toString(),
                  isToday: isToday,
                  textColor: isInCurrentMonth
                      ? null
                      : Theme.of(context).disabledColor,
                  todayTextColor: Theme.of(context).colorScheme.onPrimary,
                  todayBackgroundColor: Theme.of(context).colorScheme.primary,
                );
              },
              dayEventBuilder: (event, w, h) {
                // 이벤트 세그먼트 렌더링: 연속 이벤트 블록 처리
                final model = event.data as ScheduleModel;
                final idx = event.daysIndex ?? 0;
                final totalDays = ((event.effectiveEndTime ?? event.endTime)!
                    .difference(event.effectiveStartTime ?? event.startTime)
                    .inDays) +
                    1;
                final segStartDate = (event.effectiveStartTime ?? event.startTime)
                    .withoutTime
                    .add(Duration(days: idx));
                final wd0 = segStartDate.weekday % 7;
                final remain = 7 - wd0;
                final spanThisWeek = min(totalDays - idx, remain);
                if (spanThisWeek <= 0) return const SizedBox.shrink();
                final width = (w ?? 0) * spanThisWeek;
                final height = h ?? 0;

                return GestureDetector(
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EventDetailPage(schedule: model),
                      ),
                    );
                    if (changed == true) {
                      await context.read<ScheduleViewModel>().loadSchedules();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: DraggableMonthEvent(
                      onDragEnd: (d) => _controller.calendarData.moveEvent(event, d),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: event.color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.title ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: event.textColor.computeLuminance() < 0.4
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}