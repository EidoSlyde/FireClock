import 'package:fireclock/task_list.dart';
import 'package:flutter/material.dart';
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

class FireClockApp extends ConsumerWidget {
  const FireClockApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Task(
        name: "Computer Science",
        color: Colors.blue.shade400,
        children: [
          Task(
            name: "Web Development",
            color: Colors.orange.shade400,
            children: [
              Task(name: "Learn Angular", color: Colors.green.shade400),
              Task(
                  name: "Finish Eidovote backend",
                  selected: true,
                  color: Colors.green.shade400),
              Task(name: "BEM Conventions", color: Colors.green.shade400),
            ],
          ),
          Task(
            name: "System Programming",
            color: Colors.orange.shade400,
            children: [
              Task(name: "Learn x86 assembly", color: Colors.green.shade400),
              Task(name: "Learn C++", color: Colors.green.shade400),
              Task(name: "Game engine in Rust", color: Colors.green.shade400),
            ],
          )
        ],
      ),
    );
  }
}
