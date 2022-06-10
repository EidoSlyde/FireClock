class Task {
  Task({
    required this.id,
    required this.name,
    required this.quota,
    required this.quotaTimeUnit,
    this.children = const [],
  });

  final int id;
  final String name;
  final int quota;
  final QuotaTimeUnit quotaTimeUnit;
  final List<Task> children;

  Task? filterMapRec(Task? Function(Task) f) {
    final t = f(this);
    if (t == null) return null;
    return t.copyWith(
        children: t.children
            .map((t2) => t2.filterMapRec(f))
            .whereType<Task>()
            .toList());
  }

  Task copyWith({
    List<Task>? children,
    String? name,
    int? quota,
    QuotaTimeUnit? quotaTimeUnit,
  }) =>
      Task(
          id: id,
          name: name ?? this.name,
          quota: quota ?? this.quota,
          quotaTimeUnit: quotaTimeUnit ?? this.quotaTimeUnit,
          children: children ?? this.children);
}

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
