import 'package:fireclock/services/task_service.dart';
import 'package:fireclock/services/user_service.dart';
import 'package:fireclock/task.dart';
import 'package:fireclock/widgets/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rxdart/rxdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    return TaskList(
      tasks,
      onAddTask: () => taskService.createTask(
        userId: user.userId,
        taskName: "New Task",
      ),
      onMove: (t, p, i) => taskService.reorderTask(
        taskId: t.id,
        newParentId: p?.id,
        newChildrenIndex: i,
      ),
    );
  }
}
