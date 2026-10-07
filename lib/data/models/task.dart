import 'project_ref.dart';
import 'comment.dart';

class Task {
  const Task({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.priority,
    this.startDate,
    this.dueDate,
    this.projectId,
    this.assignees = const [],
    this.project,
    this.comments = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String? description;
  final String? status;
  final String? priority; // lowercase
  final DateTime? startDate;
  final DateTime? dueDate;
  final int? projectId;
  final List<Assignee> assignees;

  // Detail-only fields:
  final ProjectRef? project;
  final List<Comment> comments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawAssignees =
        (json['Assignees'] ?? json['assignees']) as List? ?? const [];
    final rawComments =
        (json['Comments'] ?? json['comments']) as List? ?? const [];
    final rawProject = (json['Project'] ?? json['project']) as Map?;

    return Task(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      status: json['status'] as String?,
      priority: _normalizePriority(
        (json['priority'] ?? json['Priority']) as String?,
      ),
      startDate: _parseDate(json['startedDate'] ?? json['start_date']),
      dueDate: _parseDate(json['dueDate'] ?? json['due_date']),
      projectId: (json['projectId'] ?? json['project_id']) as int?,
      assignees: rawAssignees
          .whereType<Map>()
          .map((e) => Assignee.fromJson(e.cast<String, dynamic>()))
          .toList(),
      project: rawProject != null
          ? ProjectRef.fromJson(rawProject.cast<String, dynamic>())
          : null,
      comments: rawComments
          .whereType<Map>()
          .map((e) => Comment.fromJson(e.cast<String, dynamic>()))
          .toList(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static String? _normalizePriority(String? raw) => raw?.toLowerCase();

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }
}

class Assignee {
  const Assignee({required this.id, required this.fullName});

  final int id;
  final String fullName;

  factory Assignee.fromJson(Map<String, dynamic> json) {
    return Assignee(
      id: (json['id'] as num).toInt(),
      fullName: (json['full_name'] ?? json['name'] ?? '') as String,
    );
  }
}
