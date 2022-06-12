import 'package:fireclock/task.dart';
import 'package:fireclock/widgets/activities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pie_chart/pie_chart.dart';

import '../services/activity_service.dart';

class SubTaskDistribution extends HookConsumerWidget {
  SubTaskDistribution({
    required this.selectedTask,
    required this.activities,
    Key? key,
  }) : super(key: key);

  final List<ActivityData> activities;
  final Task selectedTask;
  final DateTimeRange selectedRange =
      DateTimeRange(start: DateTime(1970), end: DateTime(2090));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityService = ref.read(activityServiceProvider);
    final map = useFuture(useMemoized(
            () => activityService.subtaskActivityDistribution(
                selectedTask.id, selectedRange),
            [selectedTask, selectedRange, activities])).data ??
        {};
    final data = useState(<String, double>{"": 0});
    useEffect(() {
      final counts = <String, int>{};
      data.value = map.map((k, v) => MapEntry(
          [selectedTask, ...selectedTask.children]
              .map((t) => t.copyWith(name: () {
                    counts[t.name] = (counts[t.name] ?? -1) + 1;
                    if (counts[t.name] == 0) return t.name;
                    return "${t.name} (${counts[t.name]})";
                  }()))
              .firstWhere((t) => t.id == k)
              .name,
          v.toDouble()));
      if (data.value.isEmpty) data.value = {"": 0};
      return;
    }, [map]);

    return PieChart(
      dataMap: data.value,
      chartValuesOptions: const ChartValuesOptions(
        showChartValues: false,
      ),
    );
  }
}
