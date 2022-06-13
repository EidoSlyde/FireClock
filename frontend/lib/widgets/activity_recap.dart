import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intersperse/intersperse.dart';
import 'package:intl/intl.dart';

import '../services/activity_service.dart';
import '../task.dart';

class ActivityRecap extends HookConsumerWidget {
  const ActivityRecap({
    required this.date,
    required this.quota,
    required this.totalActivity,
    Key? key,
  }) : super(key: key);

  final DateTime date;
  final int quota;
  final int totalActivity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    final mins = totalActivity;
    final hours = mins ~/ 60;
    final days = hours ~/ 24;

    String top, bottom;
    if (days == 0) {
      top = '${(hours % 24).toString().padLeft(2, '0')}h';
      bottom = '${(mins % 60).toString().padLeft(2, '0')}m';
    } else {
      top = '${days.toString().padLeft(2, '0')}d';
      bottom = '${(hours % 24).toString().padLeft(2, '0')}h';
    }

    final circleWidget = Center(
      child: Text(
        '$top\n$bottom',
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
      ),
    );

    final ratio = totalActivity / quota;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.white,
        width: 220,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            LayoutBuilder(
                builder: ((context, constraints) => AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    color: ratio >= 1
                        ? const Color(0xF624EB56)
                        : const Color(0xFFCE65FF),
                    height: constraints.maxHeight * ratio.clamp(0, 1)))),
            Column(
              children: [
                const SizedBox(height: 16),
                Text(dateFormat.format(date)),
                const SizedBox(height: 42),
                circleWidget,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityRecapPanel extends HookConsumerWidget {
  const ActivityRecapPanel(this.selected, {Key? key}) : super(key: key);

  final Task selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityService = ref.read(activityServiceProvider);
    final activitiesNoRec = useStream(useMemoized(
            () => activityService.activitiesOfTask(selected.id),
            [selected])).data ??
        [];
    final activitiesRec = useFuture(useMemoized(
            () => activityService.recursiveActivitiesOfTaskSum(selected.id),
            [selected, activitiesNoRec])).data ??
        [];
    final oldestActivity = activitiesRec.isEmpty
        ? null
        : activitiesRec.reduce((curr, next) =>
            curr.range.start.compareTo(next.range.start) < 0 ? curr : next);

    final now = DateTime.now();
    var intervalVar = DateTime(
        now.year,
        now.month,
        selected.quotaTimeUnit == QuotaTimeUnit.day
            ? now.day
            : selected.quotaTimeUnit == QuotaTimeUnit.week
                ? now.day - now.weekday + 1
                : 1);

    DateTime intervalEnd(DateTime start) =>
        selected.quotaTimeUnit == QuotaTimeUnit.day
            ? start.add(const Duration(days: 1))
            : selected.quotaTimeUnit == QuotaTimeUnit.week
                ? start.add(const Duration(days: 7))
                : DateTime(start.year, start.month + 1, 1);

    var xs = {intervalVar: const Duration()};
    while (oldestActivity != null &&
        intervalVar.isAfter(oldestActivity.range.start)) {
      intervalVar = selected.quotaTimeUnit == QuotaTimeUnit.day
          ? intervalVar.subtract(const Duration(days: 1))
          : selected.quotaTimeUnit == QuotaTimeUnit.week
              ? intervalVar.subtract(const Duration(days: 7))
              : DateTime(intervalVar.year, intervalVar.month - 1, 1);
      xs[intervalVar] = const Duration();
    }

    for (final activity in activitiesRec) {
      for (final itvStart in xs.keys) {
        final range =
            DateTimeRange(start: itvStart, end: intervalEnd(itvStart));
        xs[itvStart] = xs[itvStart]! +
            (activity.overlapping(range)?.duration ?? const Duration());
      }
    }

    return Container(
      color: const Color(0xFF343434),
      height: 280,
      child: Scrollbar(
        child: ListView(
          primary: true,
          scrollDirection: Axis.horizontal,
          children: [
            const SizedBox(width: 16),
            ...intersperse(
              const SizedBox(width: 16),
              [
                for (final itvStart in xs.keys)
                  ActivityRecap(
                    date: itvStart,
                    quota: selected.quota,
                    totalActivity: xs[itvStart]!.inMinutes,
                  ),
              ].map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24), child: e)),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
