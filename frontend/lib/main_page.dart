import 'package:fireclock/services/activity_service.dart';
import 'package:fireclock/services/task_service.dart';
import 'package:fireclock/services/user_service.dart';
import 'package:fireclock/task.dart';
import 'package:fireclock/widgets/activity_recap.dart';
import 'package:fireclock/widgets/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intersperse/intersperse.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTask = useState<Task?>(null);

    final userService = ref.read(userServiceProvider);
    final userSnapshot = useStream(userService.currentUser);
    if (!userSnapshot.hasData) {
      return const Text("Not connected");
    }
    final user = userSnapshot.data!;

    final taskService = ref.read(taskServiceProvider);
    final AsyncSnapshot<List<Task>> tasksSnapshot =
        useStream(taskService.getTasksOfUser(user.userId));
    if (!tasksSnapshot.hasData) return const Text("Couldn't fetch tasks");
    final tasks = tasksSnapshot.data!;
    final taskList = TaskList(
      tasks,
      onTap: (t) => selectedTask.value = selectedTask.value == t ? null : t,
      onAddTask: () => taskService.createTask(
        userId: user.userId,
        taskName: "New Task",
      ),
      onMove: (t, p, i) => taskService.reorderTask(
        taskId: t.id,
        newParentId: p?.id,
        newChildrenIndex: i,
      ),
      selected: selectedTask.value,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 320, child: taskList),
        if (selectedTask.value != null)
          Expanded(child: ActivityRecapPanel(selectedTask.value!)),
      ],
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
                    date: DateTime.now(), quota: 60 * 12, totalActivity: 650),
                ActivityRecap(
                    date: DateTime.now(), quota: 60 * 12, totalActivity: 420),
                ActivityRecap(
                    date: DateTime.now(), quota: 60 * 12, totalActivity: 263),
                ActivityRecap(
                    date: DateTime.now(), quota: 60 * 12, totalActivity: 800),
                ActivityRecap(
                    date: DateTime.now(), quota: 60 * 12, totalActivity: 900),
                ActivityRecap(
                    date: DateTime.now(), quota: 60 * 12, totalActivity: 10000),
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
