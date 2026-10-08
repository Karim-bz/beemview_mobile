import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/new_project.dart';
import '../../data/models/project.dart';
import '../../data/models/task.dart';
import '../../data/repositories/project_repository.dart';

enum ProjectsStatus { idle, loading, loaded, error }

/// Personal task counters shown on the profile screen.
class TaskStats {
  const TaskStats({this.completed = 0, this.inProgress = 0, this.overdue = 0});

  final int completed;
  final int inProgress;
  final int overdue;
}

class ProjectsProvider extends ChangeNotifier {
  ProjectsProvider(this._repo);

  final ProjectRepository _repo;
  static const int _pageSize = 10;

  ProjectsStatus _status = ProjectsStatus.idle;
  final List<Project> _projects = [];
  int _total = 0;
  String? _error;
  bool _loadingMore = false;

  ProjectsStatus get status => _status;
  List<Project> get projects => List.unmodifiable(_projects);
  String? get error => _error;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _projects.length < _total;
  bool get isEmpty => _status == ProjectsStatus.loaded && _projects.isEmpty;

  /// Counts the user's tasks across the projects loaded so far.
  /// (Derived from the tasks embedded in each project payload.)
  TaskStats statsFor(int? userId) {
    if (userId == null) return const TaskStats();
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    var completed = 0, inProgress = 0, overdue = 0;
    for (final p in _projects) {
      for (final t in p.tasks) {
        if (!t.assigneeIds.contains(userId)) continue;
        if (t.status == 'done') {
          completed++;
          continue;
        }
        if (t.status == 'canceled') continue;
        if (t.status == 'in_progress') inProgress++;
        if (t.dueDate != null && t.dueDate!.isBefore(startOfToday)) overdue++;
      }
    }
    return TaskStats(
      completed: completed,
      inProgress: inProgress,
      overdue: overdue,
    );
  }

  /// Open (not done / canceled) tasks assigned to [userId] across the
  /// projects loaded so far, soonest due date first.
  List<Task> myOpenTasks(int? userId) {
    if (userId == null) return const [];
    final out = <Task>[];
    for (final p in _projects) {
      for (final t in p.tasks) {
        if (!t.assigneeIds.contains(userId)) continue;
        if (t.status == 'done' || t.status == 'canceled') continue;
        final task = t.toTask(p.id);
        if (task != null) out.add(task);
      }
    }
    out.sort((a, b) {
      final ad = a.dueDate ?? DateTime(9999);
      final bd = b.dueDate ?? DateTime(9999);
      return ad.compareTo(bd);
    });
    return out;
  }

  /// Organizational units seen on the loaded projects (unique, by name).
  /// Used by the "new project" form, since no units endpoint is wired yet.
  List<OrganizationalUnit> get knownUnits {
    final byId = <int, OrganizationalUnit>{};
    for (final p in _projects) {
      final u = p.organizationalUnit;
      if (u != null) byId[u.id] = u;
    }
    final list = byId.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Creates a project, then reloads the list so it shows up.
  /// Throws [ApiException] so the form can display the message.
  Future<void> createProject(NewProject project) async {
    await _repo.createProject(project);
    await load();
  }

  /// Loads the first page (or reloads from scratch).
  Future<void> load() async {
    _status = ProjectsStatus.loading;
    _error = null;
    _projects.clear();
    _total = 0;
    notifyListeners();

    try {
      final page = await _repo.fetchProjects(limit: _pageSize, offset: 0);
      _projects.addAll(page.items);
      _total = page.total;
      _status = ProjectsStatus.loaded;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ProjectsStatus.error;
    }
    notifyListeners();
  }

  /// Fetches the next page and appends.
  Future<void> loadMore() async {
    if (_loadingMore || !hasMore) return;

    _loadingMore = true;
    notifyListeners();

    try {
      final page = await _repo.fetchProjects(
        limit: _pageSize,
        offset: _projects.length,
      );
      _projects.addAll(page.items);
      _total = page.total;
    } on ApiException catch (e) {
      // Keep the already-loaded list; just surface the error.
      _error = e.message;
    }
    _loadingMore = false;
    notifyListeners();
  }
}
