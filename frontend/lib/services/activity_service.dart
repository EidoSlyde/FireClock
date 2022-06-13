import 'dart:math';

import 'package:fireclock/services/task_service.dart';
import 'package:fireclock/tools.dart';
import 'package:fireclock/widgets/activities.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../task.dart';

abstract class ActivityService {
  Stream<List<ActivityData>> activitiesOfTask(int taskId);
  Future<List<ActivityData>> recursiveActivitiesOfTaskSum(int taskId);
  Future<ActivityData> createActivity(int taskId, DateTimeRange range);
  Future<void> deleteActivity(int activityId);
  Future<void> updateRange(int activityId, DateTime? start, DateTime? end);
  // Returns a map from task id to number of minutes of activity in given range
  Future<Map<int, int>> subtaskActivityDistribution(
      int taskId, DateTimeRange range);
}

class DummyActivityService extends ActivityService {
  // Maps taskId to activities
  final Map<int, BehaviorSubject<List<ActivityData>>> _db = {};

  DummyActivityService(this.taskService);

  final TaskService taskService;

  BehaviorSubject<List<ActivityData>> _getOrCreateDb(int taskId) {
    if (_db.containsKey(taskId)) return _db[taskId]!;
    final s = BehaviorSubject<List<ActivityData>>()..add([]);
    _db[taskId] = s;
    return s;
  }

  @override
  Stream<List<ActivityData>> activitiesOfTask(int taskId) =>
      _getOrCreateDb(taskId);

  @override
  Future<ActivityData> createActivity(int taskId, DateTimeRange range) async {
    final rng = Random();
    final s = _getOrCreateDb(taskId);
    final activity = ActivityData(rng.nextInt(99999), range);
    s.add([...s.value, activity]);
    return activity;
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    final s =
        _db.values.firstWhere((s) => s.value.any((a) => a.id == activityId));
    s.add([...s.value.where((a) => a.id != activityId)]);
  }

  @override
  Future<void> updateRange(
      int activityId, DateTime? start, DateTime? end) async {
    final s =
        _db.values.firstWhere((s) => s.value.any((a) => a.id == activityId));
    final activity = s.value.firstWhere((a) => a.id == activityId);
    final newActivity = ActivityData(
        activity.id,
        DateTimeRange(
            start: start ?? activity.range.start,
            end: end ?? activity.range.end));
    s.add(s.value.map((s) => s == activity ? newActivity : s).toList());
  }

  @override
  Future<Map<int, int>> subtaskActivityDistribution(
      int taskId, DateTimeRange range) async {
    final task = await taskService.getById(taskId);

    final keys = <int>[taskId];
    final vals = <int>[0];

    for (final t in recToList<Task>(task, (t) => t.children)) {
      if (t.depth == 1) {
        keys.add(t.value.id);
        vals.add(0);
      }

      final activities = await activitiesOfTask(t.value.id).first;

      for (final a in activities) {
        vals[vals.length - 1] =
            vals.last + (a.overlapping(range)?.duration.inMinutes ?? 0);
      }
    }

    final map = <int, int>{};
    for (var i = 0; i < keys.length; i++) {
      map[keys[i]] = vals[i];
    }
    return map;
  }

  @override
  Future<List<ActivityData>> recursiveActivitiesOfTaskSum(int taskId) async {
    final self = await activitiesOfTask(taskId).first;

    final task = await taskService.getById(taskId);
    final children = await Future.wait(
        task.children.map((e) => recursiveActivitiesOfTaskSum(e.id)));

    return [...self, ...children.expand((e) => e)];
  }
}

final activityServiceProvider =
    Provider((ref) => DummyActivityService(ref.read(taskServiceProvider)));
