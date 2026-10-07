import 'package:flutter/foundation.dart';

import '../../core/api_exception.dart';
import '../../data/models/project.dart';
import '../../data/repositories/project_repository.dart';

enum ProjectsStatus { idle, loading, loaded, error }

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
