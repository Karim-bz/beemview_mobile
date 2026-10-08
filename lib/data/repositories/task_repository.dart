import 'package:beemview_mobile/core/api_paths.dart';

import '../../core/api_client.dart';
import '../models/new_task.dart';
import '../models/task.dart';

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

  Future<Task> updateStatus({
    required int taskId,
    required String status,
  }) async {
    final res = await _api.put<Map<String, dynamic>>(
      '${ApiPaths.tasks}$taskId',
      data: {'status': status},
    );
    final task = (res.data?['task'] as Map?)?.cast<String, dynamic>() ?? {};
    return Task.fromJson(task);
  }

  Future<void> addComment({
    required int taskId,
    required String content,
  }) async {
    await _api.post<Map<String, dynamic>>(
      ApiPaths.addCommentToTask,
      data: {
        'task_id': taskId,
        'content': content,
        'mentioned_user_ids': const <int>[],
      },
    );
  }

  Future<void> createTask(NewTask task) async {
    await _api.post<Map<String, dynamic>>(
      ApiPaths.createTask,
      data: task.toJson(),
    );
  }
}
