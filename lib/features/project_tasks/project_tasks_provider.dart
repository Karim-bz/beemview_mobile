import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

enum TasksStatus { idle, loading, loaded, error }

class ProjectTasksProvider extends ChangeNotifier {
  ProjectTasksProvider(this._repo);

  final TaskRepository _repo;

  TasksStatus _status = TasksStatus.idle;
  String _projectName = '';
  List<Task> _allTasks = const [];
  String? _error;
  int? _projectId;

  TasksStatus get status => _status;
  String get projectName => _projectName;
  List<Task> get tasks => _allTasks;
  String? get error => _error;

  Future<void> load(int projectId) async {
    _projectId = projectId;
    _status = TasksStatus.loading;
    _error = null;
    _allTasks = const [];
    notifyListeners();

    try {
      final result = await _repo.fetchProjectTasks(projectId);
      _projectName = result.projectName;
      _allTasks = result.tasks;
      _status = TasksStatus.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _status = TasksStatus.error;
    }
    notifyListeners();
  }

  Future<void> reload() async {
    if (_projectId == null) return;
    await load(_projectId!);
  }
}
