import 'dart:math';

import 'package:fireclock/services/http/http_task_service.dart';
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

  Future<Task> getById(int taskId);

  Future<void> renameTask({required int taskId, required String newName});
  Future<void> updateQuotaTimeUnit(
      {required int taskId, required QuotaTimeUnit newQuotaTimeUnit});
  Future<void> updateQuota({required int taskId, required int newQuota});
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
    final task = Task(
        id: rng.nextInt(999999),
        name: taskName,
        quota: 60,
        quotaTimeUnit: QuotaTimeUnit.day);
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
              : t.copyWith(children: () {
                  final xs2 = [...t.children];
                  xs2.insert(newChildrenIndex, task!);
                  return xs2;
                }())))
          .whereType<Task>()
          .toList());
    }
  }

  @override
  Future<void> renameTask(
      {required int taskId, required String newName}) async {
    for (final kv in _db.entries) {
      kv.value.add(kv.value.value
          .map((t2) => t2.filterMapRec(
              (t) => t.id != taskId ? t : t.copyWith(name: newName)))
          .whereType<Task>()
          .toList());
    }
  }

  @override
  Future<void> updateQuota({required int taskId, required int newQuota}) async {
    for (final kv in _db.entries) {
      kv.value.add(kv.value.value
          .map((t2) => t2.filterMapRec(
              (t) => t.id != taskId ? t : t.copyWith(quota: newQuota)))
          .whereType<Task>()
          .toList());
    }
  }

  @override
  Future<void> updateQuotaTimeUnit(
      {required int taskId, required QuotaTimeUnit newQuotaTimeUnit}) async {
    for (final kv in _db.entries) {
      kv.value.add(kv.value.value
          .map((t2) => t2.filterMapRec((t) =>
              t.id != taskId ? t : t.copyWith(quotaTimeUnit: newQuotaTimeUnit)))
          .whereType<Task>()
          .toList());
    }
  }

  @override
  Future<Task> getById(int taskId) async {
    for (final kv in _db.entries) {
      Task? task;
      kv.value.value
          .map((t2) => t2.filterMapRec((t) {
                if (t.id == taskId) task = t;
                return t;
              }))
          .whereType<Task>()
          .toList();
      if (task != null) return task!;
    }
    throw Exception("Task not found");
  }
}

final Provider<TaskService> taskServiceProvider =
    Provider((ref) => HttpTaskService());
