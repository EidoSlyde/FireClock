import 'dart:convert';

import 'package:fireclock/services/task_service.dart';
import 'package:fireclock/task.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import 'http_settings.dart';

enum _TaskEvent {
  create,
  rename,
  updateQuota,
  updateQuotaTimeUnit,
  reorder,
}

class HttpTaskService extends TaskService {
  final _events = PublishSubject<_TaskEvent>();

  @override
  Future<Task> createTask(
      {required int userId, required String taskName}) async {
    final res = await http.post(Uri.parse('$apiUrl/task'), body: {
      "name": taskName,
      "user_id": userId.toString(),
    });

    _events.add(_TaskEvent.create);

    return Task.fromJSON(jsonDecode(res.body));
  }

  @override
  Future<Task> getById(int taskId) async {
    final res = await http.get(Uri.parse('$apiUrl/task/$taskId'));
    return Task.fromJSON(jsonDecode(res.body));
  }

  @override
  Stream<List<Task>> getTasksOfUser(int userId) async* {
    final res = await http.get(Uri.parse('$apiUrl/task/of_user/$userId'));
    final jsonList = json.decode(res.body) as List<dynamic>;

    final xs = <int, Tuple2<Task, int?>>{};
    for (final json in jsonList) {
      final task = Task.fromJSON(json);
      xs[task.id] = Tuple2(task, json["parent"]);
    }
    for (final taskId in xs.keys) {
      final parentId = xs[taskId]!.item2;
      final task = xs[taskId]!.item1;
      if (parentId == null) continue;
      final p = xs[parentId]!.item1;
      p.children.add(task);
    }
    final tasks =
        xs.values.where((t) => t.item2 == null).map((t) => t.item1).toList();

    yield tasks;
    await _events.first;
    yield* getTasksOfUser(userId);
  }

  @override
  Future<void> renameTask(
      {required int taskId, required String newName}) async {
    await http.put(Uri.parse('$apiUrl/task/$taskId'), body: {"name": newName});
    _events.add(_TaskEvent.rename);
  }

  @override
  Future<void> reorderTask(
      {required int taskId,
      required int? newParentId,
      required int newChildrenIndex}) async {
    await http.put(Uri.parse('$apiUrl/task/$taskId'), body: {
      "parent": newParentId == null ? "noparent" : newParentId.toString(),
    });
    // TODO: Ordering of children
    _events.add(_TaskEvent.reorder);
  }

  @override
  Future<void> updateQuota({required int taskId, required int newQuota}) async {
    await http.put(Uri.parse('$apiUrl/task/$taskId'),
        body: {"quota": newQuota.toString()});
    _events.add(_TaskEvent.updateQuota);
  }

  @override
  Future<void> updateQuotaTimeUnit(
      {required int taskId, required QuotaTimeUnit newQuotaTimeUnit}) async {
    await http.put(Uri.parse('$apiUrl/task/$taskId'),
        body: {"quotaInterval": newQuotaTimeUnit.toString()});
    _events.add(_TaskEvent.updateQuotaTimeUnit);
  }
}
