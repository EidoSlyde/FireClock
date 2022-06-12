import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ActivityData {
  final int id;
  final DateTimeRange range;

  ActivityData(this.id, this.range);
}

class ActivityPanel extends ConsumerWidget {
  const ActivityPanel({
    Key? key,
    required this.activities,
    this.onEndChange,
    this.onStartChange,
    this.onDelete,
    this.onCreate,
  }) : super(key: key);

  final List<ActivityData> activities;
  final Function(int id, DateTime newStart)? onStartChange;
  final Function(int id, DateTime newEnd)? onEndChange;
  final Function(int id)? onDelete;
  final Function(DateTimeRange)? onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget row(Widget start, Widget end, Widget delete) => Row(
          children: [
            start,
            Container(
                width: 64,
                transform: Matrix4.identity()..translate(0.0, 7.0),
                child: const Icon(Icons.arrow_right_alt, size: 42)),
            end,
            Container(
                width: 64,
                transform: Matrix4.identity()..translate(0.0, 8.0),
                child: delete),
          ],
        );

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              "Activities",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 142),
            GestureDetector(
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(Icons.add),
                ),
                onTap: () => onCreate?.call(DateTimeRange(
                    start: DateTime.now(),
                    end: DateTime.now().add(const Duration(hours: 1))))),
          ],
        ),
        const SizedBox(height: 16),
        for (final activity in [
          ...activities
        ]..sort((a, b) => b.range.start.compareTo(a.range.start)))
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
            ),
            child: row(
              GestureDetector(
                onTap: () {
                  DatePicker.showDateTimePicker(
                    context,
                    showTitleActions: true,
                    onConfirm: (dt) {
                      onStartChange?.call(activity.id, dt);
                    },
                    currentTime: activity.range.start,
                    maxTime: activity.range.end,
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Column(children: [
                    Text(dateFormat.format(activity.range.start),
                        style: const TextStyle(color: Colors.grey)),
                    Text(timeFormat.format(activity.range.start),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            height: 1)),
                  ]),
                ),
              ),
              GestureDetector(
                onTap: () {
                  DatePicker.showDateTimePicker(
                    context,
                    showTitleActions: true,
                    onConfirm: (dt) {
                      onEndChange?.call(activity.id, dt);
                    },
                    currentTime: activity.range.end,
                    minTime: activity.range.start,
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Column(children: [
                    Text(dateFormat.format(activity.range.end),
                        style: const TextStyle(color: Colors.grey)),
                    Text(timeFormat.format(activity.range.end),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            height: 1)),
                  ]),
                ),
              ),
              GestureDetector(
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(Icons.delete),
                  ),
                  onTap: () => onDelete?.call(activity.id)),
            ),
          ),
      ],
    );
  }
}
