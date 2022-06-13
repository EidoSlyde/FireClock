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

  static Task fromJSON(dynamic json) {
    return Task(
      id: json["task_id"],
      name: json["name"],
      quota: json["quota"],
      quotaTimeUnit: QuotaTimeUnit.fromString(json["quotaInterval"]),
      children: [
        for (final child in json["children"] ?? []) Task.fromJSON(child)
      ],
    );
  }
}

enum QuotaTimeUnit {
  day,
  week,
  month;

  static QuotaTimeUnit fromString(String str) {
    if (str == "day") return QuotaTimeUnit.day;
    if (str == "week") return QuotaTimeUnit.week;
    if (str == "month") return QuotaTimeUnit.month;
    throw Exception("Unknown QuotaTimeUnit: $str");
  }

  @override
  String toString() {
    if (this == QuotaTimeUnit.day) return "day";
    if (this == QuotaTimeUnit.week) return "week";
    if (this == QuotaTimeUnit.month) return "month";
    throw Exception("Unknown QuotaTimeUnit: $this");
  }
}

enum ActivityTimeUnit {
  minute,
  hour,
  day,
}
