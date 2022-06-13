import 'dart:convert';

import 'package:fireclock/services/activity_service.dart';
import 'package:fireclock/services/http/http_settings.dart';
import 'package:fireclock/widgets/activities.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

enum _ActivityEvt { create, delete, update }

class HttpActivityService extends ActivityService {
  final _events = PublishSubject<_ActivityEvt>();

  HttpActivityService(super.taskService);

  @override
  Stream<List<ActivityData>> activitiesOfTask(int taskId) async* {
    yield await activitiesOfTaskFuture(taskId);
    await _events.first;
    yield* activitiesOfTask(taskId);
  }

  @override
  Future<List<ActivityData>> activitiesOfTaskFuture(int taskId) async {
    final res = await http.get(Uri.parse("$apiUrl/activity/bytask/$taskId"));
    return [for (final j in json.decode(res.body)) ActivityData.fromJSON(j)];
  }

  @override
  Future<ActivityData> createActivity(int taskId, DateTimeRange range) async {
    final res = await http.post(Uri.parse("$apiUrl/activity"), body: {
      "task_id": taskId.toString(),
      "start_date": range.start.toIso8601String(),
      "end_date": range.end.toIso8601String(),
    });

    _events.add(_ActivityEvt.create);

    return ActivityData.fromJSON(jsonDecode(res.body));
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    await http.delete(Uri.parse("$apiUrl/activity/$activityId"));
    _events.add(_ActivityEvt.delete);
  }

  @override
  Future<void> updateRange(
      int activityId, DateTime? start, DateTime? end) async {
    await http.put(Uri.parse("$apiUrl/activity/$activityId"), body: {
      "start_date": start?.toIso8601String(),
      "end_date": end?.toIso8601String(),
    });
    _events.add(_ActivityEvt.update);
  }
}
