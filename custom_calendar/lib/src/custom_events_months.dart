import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sticky_infinite_list_plus/models/alignments.dart';
import 'package:sticky_infinite_list_plus/widget.dart';

import 'controller/events_controller.dart';
import 'events/event.dart';
import 'widgets/month/header.dart';
import 'widgets/month/month.dart';

class CustomEventsMonths extends StatefulWidget {
  const CustomEventsMonths({
    super.key,
    required this.controller,
    this.initialMonth,
    this.maxPreviousMonth = 120,
    this.maxNextMonth = 120,
    this.weekParam = const WeekParam(),
    this.daysParam = const DaysParam(),
    this.onMonthChange,
    this.automaticAdjustScrollToStartOfMonth = true,
    this.verticalScrollPhysics = const BouncingScrollPhysics(
      decelerationRate: ScrollDecelerationRate.fast,
    ),
    this.showWebScrollBar = false,
    this.pinchToZoomParam = const PinchToZoom(),
  });

  /// data controller
  final EventsController controller;

  /// initial first day
  final DateTime? initialMonth;

  /// max horizontal previous days scroll
  /// Null for infinite
  final int? maxPreviousMonth;

  /// max horizontal next days scroll
  /// Null for infinite
  final int? maxNextMonth;

  /// week param
  final WeekParam weekParam;

  /// day param
  final DaysParam daysParam;

  /// Callback when month change during vertical scroll
  final void Function(DateTime monthFirstDay)? onMonthChange;

  /// Automatic adjust scroll to nearest month and background
  final bool automaticAdjustScrollToStartOfMonth;

  /// Vertical day scroll physics
  final ScrollPhysics verticalScrollPhysics;

  /// show scroll bar for web
  final bool showWebScrollBar;

  final PinchToZoom pinchToZoomParam;

  @override
  State createState() => CustomEventsMonthsState();
}

class CustomEventsMonthsState extends State<CustomEventsMonths> {
  late ScrollController scrollController;
  late DateTime initialMonth;
  late DateTime _stickyMonth;
  late double _stickyPercent;
  late double _stickyOffset;
  late double scrollStartOffset;
  late double weekHeight;
  late double weekHeightScaleStart;
  late double scrollControllerOffsetScaleStart;
  late VoidCallback automaticScrollAdjustListener;
  bool _blockAdjustScroll = false;
  bool scrollIsStopped = true;
  int maxEventsShowed = 0;
  int _pointerDownCount = 0;

  @override
  void initState() {
    super.initState();
    weekHeight = widget.weekParam.weekHeight;
    var initialDay = widget.initialMonth ?? widget.controller.focusedDay;
    initialMonth = DateTime(initialDay.year, initialDay.month);
    _stickyMonth = initialMonth;
    scrollController = ScrollController();
    maxEventsShowed = getMaxEventsCanBeShowed();

    if (widget.automaticAdjustScrollToStartOfMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        automaticScrollAdjustListener = getAutomaticScrollAdjustListener();
        scrollController.position.isScrollingNotifier
            .addListener(automaticScrollAdjustListener);
      });
    }
  }

  // when scroll end, auto adjust to start of month
  // if it's small scroll, like mouse wheel (web), not adjust (only possibility to differentiates mouse wheel to finger scroll)
  VoidCallback getAutomaticScrollAdjustListener() {
    return () {
      scrollIsStopped = !scrollController.position.isScrollingNotifier.value;
      if (scrollIsStopped &&
          ((scrollStartOffset - scrollController.offset).abs() > 10)) {
        var scroll = scrollController;
        if (!_blockAdjustScroll) {
          var adjustedOffset = _stickyPercent < 0.5
              ? scroll.offset - _stickyOffset
              : scroll.offset +
              (((1 - _stickyPercent) * _stickyOffset) / _stickyPercent);

          Future.delayed(const Duration(milliseconds: 1), () {
            if (scrollIsStopped) {
              _blockAdjustScroll = true;
              scroll.animateTo(
                adjustedOffset,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );
            }
          });
        } else {
          _blockAdjustScroll = false;
        }
      }
    };
  }

  void jumpToDateCustom(DateTime targetDate) {
    setState(() {});

    final index = _calculateMonthIndex(targetDate);
    final position = index * _estimatedMonthHeight;

    scrollController.animateTo(
      position,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  int _calculateMonthIndex(DateTime date) {
    final now = DateTime.now();
    return (date.year - now.year) * 12 + (date.month - now.month);
  }

  double get _estimatedMonthHeight => 450;

  @override
  Widget build(BuildContext context) {
    var zoom = widget.pinchToZoomParam;
    var isZoom = zoom.pinchToZoom;

    return GestureDetector(
      onScaleStart: isZoom ? zoom.onScaleStart ?? _onScaleStart : null,
      onScaleUpdate: isZoom ? zoom.onScaleUpdate ?? _onScaleUpdate : null,
      onScaleEnd: isZoom ? zoom.onScaleEnd ?? _onScaleEnd : null,
      child: Listener(
        onPointerDown: isZoom ? (event) => _onPointerDown() : null,
        onPointerCancel: isZoom ? (event) => _onPointerUp() : null,
        onPointerUp: isZoom ? (event) => _onPointerUp() : null,
        child: Column(
          children: [
            // week header
            MonthHeader(
              weekParam: WeekParam(
                startOfWeekDay: widget.weekParam.startOfWeekDay,
                weekDecoration: widget.weekParam.weekDecoration,
                weekHeight: widget.weekParam.weekHeight,
                daySpacing: widget.weekParam.daySpacing,
                headerHeight: widget.weekParam.headerHeight,
                headerStyle: widget.weekParam.headerStyle,
                headerDayBuilder: widget.weekParam.headerDayBuilder,
                headerDayText: widget.weekParam.headerDayText,
                headerDayTextColor: (int dayOfWeek) {
                  if (dayOfWeek == 6 || dayOfWeek == 7) {
                    return Colors.redAccent;
                  }
                  return widget.weekParam.headerDayTextColor?.call(dayOfWeek) ?? Colors.black;
                },
              ),
            ),

            // months
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: widget.showWebScrollBar,
                  dragDevices: PointerDeviceKind.values.toSet(),
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (widget.automaticAdjustScrollToStartOfMonth &&
                        notification is ScrollStartNotification) {
                      scrollStartOffset = scrollController.offset;
                    }
                    return true;
                  },
                  child: AbsorbPointer(
                    absorbing: isZoom ? _pointerDownCount > 1 : false,
                    child: InfiniteList(
                      controller: scrollController,
                      direction: InfiniteListDirection.multi,
                      negChildCount: widget.maxPreviousMonth,
                      posChildCount: widget.maxNextMonth,
                      physics: isZoom && _pointerDownCount > 1
                          ? const NeverScrollableScrollPhysics()
                          : widget.verticalScrollPhysics,
                      builder: (context, index) {
                        var month = DateTime(
                          initialMonth.year,
                          initialMonth.month + index,
                        );
                        return InfiniteListItem(
                          headerStateBuilder: (context, state) {
                            if (state.sticky && _stickyMonth != month) {
                              _stickyMonth = month;
                              Future(() {
                                widget.controller.updateFocusedDay(_stickyMonth);
                                widget.onMonthChange?.call(_stickyMonth);
                              });
                            }
                            _stickyPercent = state.position;
                            _stickyOffset = state.offset;
                            return SizedBox.shrink();
                          },
                          contentBuilder: (context) {
                            return Month(
                              controller: widget.controller,
                              month: month,
                              weekParam: widget.weekParam,
                              weekHeight: weekHeight,
                              daysParam: widget.daysParam,
                              maxEventsShowed: maxEventsShowed,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void jumpToDate(DateTime date) {
    if (context.mounted) {
      setState(() {
        initialMonth = DateTime(date.year, date.month);
      });
      scrollController.jumpTo(0);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.notifyListeners();
      });
    }
  }

  int getMaxEventsCanBeShowed() {
    var dayParam = widget.daysParam;
    var dayHeight = weekHeight;
    var headerHeight = dayParam.headerHeight;
    var eventHeight = dayParam.eventHeight;
    var space = dayParam.eventSpacing;
    var beforeEventSpacing = dayParam.spaceBetweenHeaderAndEvents;
    return ((dayHeight - headerHeight - beforeEventSpacing + space) /
        (eventHeight + space))
        .toInt();
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (details.pointerCount == 2) {
      weekHeightScaleStart = weekHeight;
      scrollControllerOffsetScaleStart = scrollController.offset;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 2) {
      var speed = widget.pinchToZoomParam.pinchToZoomSpeed;
      var scale = (((details.scale - 1) * speed) + 1);
      var newWeekHeight = weekHeightScaleStart * scale;
      var minZoom = widget.pinchToZoomParam.pinchToZoomMinWeekHeight;
      var maxZoom = widget.pinchToZoomParam.pinchToZoomMaxWeekHeight;
      if (minZoom <= newWeekHeight && newWeekHeight <= maxZoom) {
        setState(() {
          weekHeight = newWeekHeight;
          scrollController.jumpTo(scrollControllerOffsetScaleStart * scale);
          maxEventsShowed = getMaxEventsCanBeShowed();
        });
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    widget.controller.notifyListeners();
    widget.pinchToZoomParam.onZoomChange?.call(weekHeight);
    if (widget.automaticAdjustScrollToStartOfMonth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.position.isScrollingNotifier
            .removeListener(automaticScrollAdjustListener);
        scrollController.position.isScrollingNotifier
            .addListener(automaticScrollAdjustListener);
      });
    }
  }

  void _onPointerDown() {
    setState(() {
      _pointerDownCount++;
    });
  }

  void _onPointerUp() {
    setState(() {
      _pointerDownCount--;
    });
  }
}

class WeekParam {
  const WeekParam({
    this.startOfWeekDay = 7,
    this.weekDecoration,
    this.weekHeight = 117.0,
    this.daySpacing = 4.0,
    this.headerHeight = 45,
    this.headerStyle,
    this.headerDayBuilder,
    this.headerDayText,
    this.headerDayTextColor,
  });

  /// start day of week : 1 = monday, 7 = sunday
  final int startOfWeekDay;

  final BoxDecoration? weekDecoration;
  final double weekHeight;
  final double daySpacing;
  final double headerHeight;
  final TextStyle? headerStyle;
  final Widget Function(int dayOfWeek)? headerDayBuilder;
  final String Function(int dayOfWeek)? headerDayText;
  final Color Function(int dayOfWeek)? headerDayTextColor;

  static BoxDecoration defaultWeekDecoration(BuildContext context) {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          width: 0.5,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

class DaysParam {
  const DaysParam({
    this.headerHeight = 25.0,
    this.eventHeight = 20.0,
    this.eventSpacing = 2.0,
    this.spaceBetweenHeaderAndEvents = 6.0,
    this.onMonthChange,
    this.dayHeaderBuilder,
    this.dayEventBuilder,
    this.dayMoreEventsBuilder,
    this.onDayTapDown,
    this.onDayTapUp,
  });

  final double headerHeight;
  final double eventHeight;
  final double eventSpacing;
  final double spaceBetweenHeaderAndEvents;
  final void Function(DateTime month)? onMonthChange;
  final Widget Function(DateTime day)? dayHeaderBuilder;
  final Widget Function(Event event, double? width, double? height)? dayEventBuilder;
  final Widget Function(int count)? dayMoreEventsBuilder;
  final void Function(DateTime day)? onDayTapDown;
  final void Function(DateTime day)? onDayTapUp;
}

class PinchToZoom {
  const PinchToZoom({
    this.pinchToZoom = true,
    this.pinchToZoomSpeed = 1,
    this.pinchToZoomMinWeekHeight = 80,
    this.pinchToZoomMaxWeekHeight = 160,
    this.onZoomChange,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
  });

  final bool pinchToZoom;
  final double pinchToZoomSpeed;
  final double pinchToZoomMinWeekHeight;
  final double pinchToZoomMaxWeekHeight;
  final void Function(double heightPerMinute)? onZoomChange;
  final void Function(ScaleStartDetails details)? onScaleStart;
  final void Function(ScaleUpdateDetails details)? onScaleUpdate;
  final void Function(ScaleEndDetails details)? onScaleEnd;
}