import 'package:fireclock/widgets/activities.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

abstract class ActivityService {
  Stream<List<ActivityData>> activitiesOfTask(int taskId);
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

  //
}

final activityServiceProvider = Provider((ref) => DummyActivityService());
