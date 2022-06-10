class Task {
  Task({required this.id, required this.name, this.children = const []});

  final int id;
  final String name;
  final List<Task> children;

  Task? filterMapRec(Task? Function(Task) f) {
    final t = f(this);
    if (t == null) return null;
    return t.cloneWithChildren(
        (xs) => xs.map((t2) => t2.filterMapRec(f)).whereType<Task>().toList());
  }

  Task cloneWithChildren(List<Task> Function(List<Task>) f) =>
      Task(id: id, name: name, children: f(children));
}

final exampleTasks = [
  Task(id: 1, name: "Computer Science", children: [
    Task(id: 2, name: "Web Development", children: [
      Task(id: 3, name: "Learn Angular"),
      Task(id: 4, name: "Finish Eidovote backend"),
      Task(id: 5, name: "BEM Conventions"),
    ]),
    Task(id: 6, name: "System Programming", children: [
      Task(id: 7, name: "Learn x86 assembly"),
      Task(id: 8, name: "Learn C++"),
      Task(id: 9, name: "Game engine in Rust"),
    ]),
  ]),
  Task(id: 10, name: "Music", children: [
    Task(id: 11, name: "Learn piano"),
    Task(id: 12, name: "Learn guitar"),
    Task(id: 13, name: "Learn drums"),
    Task(id: 14, name: "Live Looping", children: [
      Task(id: 15, name: "Improvisation session"),
      Task(id: 16, name: "Ableton template setup"),
      Task(id: 17, name: "Rhythm training", children: [
        Task(id: 18, name: "Dance loop in one try"),
      ]),
    ]),
  ]),
  Task(id: 19, name: "Sports", children: [
    Task(id: 20, name: "Running"),
    Task(id: 21, name: "Workout"),
  ]),
];

enum QuotaTimeUnit {
  day,
  week,
  month,
}

enum ActivityTimeUnit {
  minute,
  hour,
  day,
}
