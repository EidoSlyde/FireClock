import 'package:fireclock/services/activity_service.dart';
import 'package:fireclock/services/task_service.dart';
import 'package:fireclock/services/user_service.dart';
import 'package:fireclock/task.dart';
import 'package:fireclock/widgets/activities.dart';
import 'package:fireclock/widgets/activity_recap.dart';
import 'package:fireclock/widgets/subtask_distribution.dart';
import 'package:fireclock/widgets/task_widget.dart';
import 'package:fireclock/widgets/task_top_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'login_page.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTask = useState<Task?>(null);

    final userService = ref.read(userServiceProvider);
    final userSnapshot = useStream(userService.currentUser);
    if (!userSnapshot.hasData) {
      return const LoginPage();
    }
    final user = userSnapshot.data!;

    final taskService = ref.read(taskServiceProvider);
    final AsyncSnapshot<List<Task>> tasksSnapshot = useStream(useMemoized(
        () => taskService.getTasksOfUser(user.userId), [user.userId]));

    if (!tasksSnapshot.hasData) return const Text("Couldn't fetch tasks");
    final tasks = tasksSnapshot.data!;
    useEffect(() {
      if (selectedTask.value == null) return;
      taskService
          .getById(selectedTask.value!.id)
          .then((t) => selectedTask.value = t);
      return null;
    }, [tasks]);

    final activityService = ref.read(activityServiceProvider);
    final activitiesSnapshot = useStream(
      useMemoized(
          () => selectedTask.value == null
              ? Stream.value(null)
              : activityService.activitiesOfTask(selectedTask.value!.id),
          [selectedTask.value]),
    );
    final activities = activitiesSnapshot.data ?? [];

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
          Expanded(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TaskTopInfo(
                  key: ValueKey(selectedTask.value!.id),
                  task: selectedTask.value!,
                  onQuotaChange: (quota) => taskService.updateQuota(
                      taskId: selectedTask.value!.id, newQuota: quota),
                  onQuotaTimeUnitChange: (quotaTimeUnit) =>
                      taskService.updateQuotaTimeUnit(
                          taskId: selectedTask.value!.id,
                          newQuotaTimeUnit: quotaTimeUnit),
                  onNameChange: (name) => taskService.renameTask(
                      taskId: selectedTask.value!.id, newName: name),
                ),
              ),
              SizedBox(
                height: 280,
                child: ActivityRecapPanel(selectedTask.value!),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 292,
                        child: ActivityPanel(
                          activities: activities,
                          onCreate: (dtr) => activityService.createActivity(
                              selectedTask.value!.id, dtr),
                          onDelete: (aid) =>
                              activityService.deleteActivity(aid),
                          onStartChange: (aid, dtr, duration) => activityService
                              .updateRange(aid, dtr, dtr.add(duration)),
                          onEndChange: (aid, dtr) =>
                              activityService.updateRange(aid, null, dtr),
                        ),
                      ),
                      Expanded(
                        child: SubTaskDistribution(
                            activities: activities,
                            selectedTask: selectedTask.value!),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          )
      ],
    );
  }
}
