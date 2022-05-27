import 'package:fireclock/task.dart';
import 'package:fireclock/widgets/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FireClockApp(),
    );
  }
}

class FireClockApp extends HookConsumerWidget {
  const FireClockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<int?> selectedTaskId = useState(null);

    final tasks = exampleTasks;
    TaskItem toTaskItem(Task task, {int level = 0}) {
      return TaskItem(
        name: task.name,
        color: taskColors[level % taskColors.length],
        selected: selectedTaskId.value == task.id,
        onSelect: () => selectedTaskId.value =
            selectedTaskId.value == task.id ? null : task.id,
        children: [
          ...task.children.map((t) => toTaskItem(t, level: level + 1))
        ],
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [...tasks.map(toTaskItem)],
        ),
      ),
    );
  }
}
