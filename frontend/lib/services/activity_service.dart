import 'dart:math';

import 'package:fireclock/widgets/activities.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

abstract class ActivityService {
  Stream<List<ActivityData>> activitiesOfTask(int taskId);
  Future<ActivityData> createActivity(int taskId, DateTimeRange range);
  Future<void> deleteActivity(int activityId);
  Future<void> updateRange(int activityId, DateTime? start, DateTime? end);
}

class DummyActivityService extends ActivityService {
  final Map<int, BehaviorSubject<List<ActivityData>>> _db =
      {}; // Maps taskId to activities

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
}

final activityServiceProvider = Provider((ref) => DummyActivityService());
