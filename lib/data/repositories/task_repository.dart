import 'package:beemview_mobile/core/api_paths.dart';

import '../../core/api_client.dart';
import '../models/task.dart';

/// Result of a project-tasks fetch. The list endpoint is unpaginated (spec §2),
/// so we return everything at once and let the UI filter locally.
class ProjectTasksResult {
  const ProjectTasksResult({required this.projectName, required this.tasks});

  final String projectName;
  final List<Task> tasks;
}

class TaskRepository {
  TaskRepository(this._api);

  final ApiClient _api;

  Future<ProjectTasksResult> fetchProjectTasks(int projectId) async {
    final res = await _api.get<Map<String, dynamic>>(
      '${ApiPaths.projectTasks}$projectId',
    );

    final body = res.data ?? {};
    final project = (body['project'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawTasks = (body['tasks'] as List?) ?? const [];

    final tasks = rawTasks
        .whereType<Map>()
        .map((e) => Task.fromJson(e.cast<String, dynamic>()))
        .toList();

    return ProjectTasksResult(
      projectName: (project['name'] ?? '') as String,
      tasks: tasks,
    );
  }

  Future<Task> fetchTask(int id) async {
    final res = await _api.get<Map<String, dynamic>>('${ApiPaths.tasks}$id');
    final task = (res.data?['task'] as Map?)?.cast<String, dynamic>() ?? {};
    return Task.fromJson(task);
  }
}
