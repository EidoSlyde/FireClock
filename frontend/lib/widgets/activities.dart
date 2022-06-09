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
            SizedBox(width: 172, child: start),
            end,
            const Spacer(),
            delete,
          ],
        );

    final dateFormat = DateFormat('dd/MM/yyyy hh:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Activities",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
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
        const SizedBox(height: 24),
        row(const Text("Start"), const Text("End"), Container()),
        const SizedBox(height: 16),
        for (final activity in activities)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: row(
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (dt) {
                          onStartChange?.call(activity.id, dt);
                        },
                      );
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(dateFormat.format(activity.range.start)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 12),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onConfirm: (dt) {
                          onEndChange?.call(activity.id, dt);
                        },
                      );
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(dateFormat.format(activity.range.end)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.edit, size: 12),
                ],
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
