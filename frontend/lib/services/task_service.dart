import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../task.dart';

abstract class TaskService {
  Stream<List<Task>> getTasksOfUser(int userId);
  Future<Task> createTask({required int userId, required String taskName});
  Future<void> reorderTask({
    required int taskId,
    required int? newParentId,
    required int newChildrenIndex,
  });
}

class DummyTaskService extends TaskService {
  final Map<int, BehaviorSubject<List<Task>>> _db = {}; // Maps userId to tasks

  BehaviorSubject<List<Task>> _getOrCreateDb(int userId) {
    if (_db.containsKey(userId)) return _db[userId]!;
    final s = BehaviorSubject<List<Task>>()..add([]);
    _db[userId] = s;
    return s;
  }

  @override
  Stream<List<Task>> getTasksOfUser(int userId) => _getOrCreateDb(userId);

  @override
  Future<Task> createTask(
      {required int userId, required String taskName}) async {
    final rng = Random();
    final task = Task(id: rng.nextInt(999999), name: taskName);
    final userdb = _getOrCreateDb(userId);
    userdb.add([task, ...userdb.value]);
    return task;
  }

  @override
  Future<void> reorderTask(
      {required int taskId,
      required int? newParentId,
      required int newChildrenIndex}) async {
    Task? task;
    BehaviorSubject<List<Task>>? udb;
    // Remove original

    for (final kv in _db.entries) {
      final newList = kv.value.value
          .map((t2) => t2.filterMapRec((t) {
                if (t.id != taskId) {
                  return t;
                } else {
                  task = t;
                  udb = kv.value;
                  return null;
                }
              }))
          .whereType<Task>()
          .toList();
      kv.value.add(newList);
    }
    if (task == null) return;

    if (newParentId == null) {
      final xs = [...udb!.value];
      xs.insert(newChildrenIndex, task!);
      udb!.add(xs);
      return;
    }

    // Add new
    for (final kv in _db.entries) {
      kv.value.add(kv.value.value
          .map((t2) => t2.filterMapRec((t) => t.id != newParentId
              ? t
              : t.cloneWithChildren((xs) {
                  final xs2 = [...xs];
                  xs2.insert(newChildrenIndex, task!);
                  return xs2;
                })))
          .whereType<Task>()
          .toList());
    }
  }
}

final Provider<TaskService> taskServiceProvider =
    Provider((ref) => DummyTaskService());
