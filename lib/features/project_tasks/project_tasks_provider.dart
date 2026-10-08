import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/new_task.dart';
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

  /// Bumped by every load / refresh / clear. A response that comes back
  /// with an old token belongs to a replaced request (e.g. the user opened
  /// another project meanwhile) and is dropped.
  int _token = 0;

  TasksStatus get status => _status;
  String get projectName => _projectName;
  List<Task> get tasks => _allTasks;
  String? get error => _error;

  /// Unique people already assigned to tasks of the loaded project.
  List<Assignee> get knownAssignees {
    final byId = <int, Assignee>{};
    for (final t in _allTasks) {
      for (final a in t.assignees) {
        byId.putIfAbsent(a.id, () => a);
      }
    }
    return byId.values.toList();
  }

  /// Forgets everything (used when the session ends).
  void clear() {
    _token++;
    _status = TasksStatus.idle;
    _projectName = '';
    _allTasks = const [];
    _error = null;
    _projectId = null;
    notifyListeners();
  }

  Future<void> load(int projectId) async {
    final token = ++_token;
    _projectId = projectId;
    _status = TasksStatus.loading;
    _error = null;
    _allTasks = const [];
    notifyListeners();

    try {
      final result = await _repo.fetchProjectTasks(projectId);
      if (token != _token) return;
      _projectName = result.projectName;
      _allTasks = result.tasks;
      _status = TasksStatus.loaded;
    } on ApiException catch (e) {
      if (token != _token) return;
      _error = e.message;
      _status = TasksStatus.error;
    }
    notifyListeners();
  }

  Future<void> reload() async {
    if (_projectId == null) return;
    await load(_projectId!);
  }

  /// Re-fetches the current project's tasks without the loading state.
  /// Does nothing if nothing is loaded yet, or if [projectId] is given and
  /// is not the project currently held here. Failures are ignored.
  Future<void> refreshSilently({int? projectId}) async {
    final current = _projectId;
    if (current == null || _status != TasksStatus.loaded) return;
    if (projectId != null && projectId != current) return;

    final token = ++_token;
    try {
      final result = await _repo.fetchProjectTasks(current);
      if (token != _token) return;
      _projectName = result.projectName;
      _allTasks = result.tasks;
      notifyListeners();
    } on ApiException {
      // Keep the data we have.
    }
  }

  /// Creates a task, then refreshes the project's tasks in place.
  /// Throws [ApiException] so the form can display the message.
  Future<void> createTask(NewTask task) async {
    await _repo.createTask(task);
    if (_status == TasksStatus.loaded) {
      await refreshSilently(projectId: task.projectId);
    } else {
      await reload();
    }
  }
}
