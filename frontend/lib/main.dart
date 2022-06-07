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
    final tasks = useState(exampleTasks);
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 90),
          Expanded(
            child: TaskList(
              tasks.value,
              onMove: ((moved, parent, childPos) {
                print({moved.name, parent?.name, childPos});
                Iterable<Task> filterRec(
                        Iterable<Task> tasks, bool Function(Task) f) =>
                    tasks.where(f).map((t) => Task(
                        id: t.id,
                        name: t.name,
                        children: filterRec(t.children, f).toList()));
                Iterable<Task> map(
                        Iterable<Task> tasks, Task Function(Task) f) =>
                    tasks.map(f).map((t) => Task(
                        id: t.id,
                        name: t.name,
                        children: map(t.children, f).toList()));
                final withoutMoved =
                    filterRec(tasks.value, (t) => t.id != moved.id);
                if (parent != null) {
                  tasks.value = map(
                    withoutMoved,
                    (t) {
                      if (t.id != parent.id) return t;
                      final children = [...t.children];
                      children.insert(childPos, moved);
                      return Task(id: t.id, name: t.name, children: children);
                    },
                  ).toList();
                }
                if (parent == null) {
                  final c = [...withoutMoved];
                  c.insert(childPos, moved);
                  tasks.value = c;
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}
