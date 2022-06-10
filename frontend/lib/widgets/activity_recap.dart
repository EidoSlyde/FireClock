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
    final activities = useStream(activityService.activitiesOfTask(selected.id));
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
                ActivityRecap(
                    date: DateTime.now(),
                    quota: selected.quota,
                    totalActivity: 720),
                ActivityRecap(
                    date: DateTime.now(),
                    quota: selected.quota,
                    totalActivity: 420),
                ActivityRecap(
                    date: DateTime.now(),
                    quota: selected.quota,
                    totalActivity: 263),
                ActivityRecap(
                    date: DateTime.now(),
                    quota: selected.quota,
                    totalActivity: 800),
                ActivityRecap(
                    date: DateTime.now(),
                    quota: selected.quota,
                    totalActivity: 900),
                ActivityRecap(
                    date: DateTime.now(),
                    quota: selected.quota,
                    totalActivity: 10000),
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
