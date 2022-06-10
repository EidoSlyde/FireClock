import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

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
                builder: ((context, constraints) => Container(
                    color: Color.fromARGB(255, 70, 157, 238),
                    height: constraints.maxHeight * ratio))),
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
