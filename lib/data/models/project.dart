import 'task.dart';

/// Minimal view of a task embedded in a project payload. Used for the
/// progress bar, avatar stack and profile stats.
class ProjectTaskLite {
  const ProjectTaskLite({
    this.id,
    this.name = '',
    this.priority,
    this.status,
    this.dueDate,
    this.assigneeIds = const [],
    this.assigneeNames = const [],
  });

  final int? id;
  final String name;
  final String? priority;
  final String? status;
  final DateTime? dueDate;
  final List<int> assigneeIds;
  final List<String> assigneeNames;

  factory ProjectTaskLite.fromJson(Map<String, dynamic> json) {
    final raw = (json['Assignees'] ?? json['assignees']) as List? ?? const [];
    final ids = <int>[];
    final names = <String>[];
    for (final a in raw.whereType<Map>()) {
      final id = a['id'];
      if (id is num) ids.add(id.toInt());
      final name = (a['full_name'] ?? a['name'])?.toString() ?? '';
      if (name.isNotEmpty) names.add(name);
    }
    final due = json['dueDate'] ?? json['due_date'];
    final rawId = json['id'];
    return ProjectTaskLite(
      id: rawId is num ? rawId.toInt() : null,
      name: (json['name'] ?? '').toString(),
      priority: (json['priority'] ?? json['Priority'])
          ?.toString()
          .toLowerCase(),
      status: json['status'] as String?,
      dueDate: due is String && due.isNotEmpty ? DateTime.tryParse(due) : null,
      assigneeIds: ids,
      assigneeNames: names,
    );
  }

  /// Converts to a list-ready [Task] (null if the payload had no id).
  Task? toTask(int projectId) {
    if (id == null) return null;
    return Task(
      id: id!,
      name: name,
      status: status,
      priority: priority,
      dueDate: dueDate,
      projectId: projectId,
    );
  }
}

class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.taskCount = 0,
    this.doneCount = 0,
    this.tasks = const [],
    this.assigneeNames = const [],
    this.organizationalUnit,
  });

  final int id;
  final String name;
  final String? description;
  final String? status;
  final int taskCount;

  /// Tasks whose status is `done`.
  final int doneCount;
  final List<ProjectTaskLite> tasks;

  /// Unique assignee names across the project's tasks.
  final List<String> assigneeNames;
  final OrganizationalUnit? organizationalUnit;

  double get progress => taskCount == 0 ? 0 : doneCount / taskCount;

  factory Project.fromJson(Map<String, dynamic> json) {
    final rawTasks = (json['Tasks'] as List?) ?? const [];
    final unit = json['OrganizationalUnit'];

    final tasks = rawTasks
        .whereType<Map>()
        .map((e) => ProjectTaskLite.fromJson(e.cast<String, dynamic>()))
        .toList();

    final names = <String>{};
    for (final t in tasks) {
      names.addAll(t.assigneeNames);
    }

    return Project(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      status: json['status'] as String?,
      taskCount: rawTasks.length,
      doneCount: tasks.where((t) => t.status == 'done').length,
      tasks: tasks,
      assigneeNames: names.toList(),
      organizationalUnit: unit is Map
          ? OrganizationalUnit.fromJson(unit.cast<String, dynamic>())
          : null,
    );
  }
}

class OrganizationalUnit {
  const OrganizationalUnit({required this.id, required this.name, this.type});

  final int id;
  final String name;
  final String? type;

  factory OrganizationalUnit.fromJson(Map<String, dynamic> json) {
    return OrganizationalUnit(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      type: json['type'] as String?,
    );
  }
}
