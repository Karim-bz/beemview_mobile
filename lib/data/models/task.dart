/// Field differences handled:
/// - `dueDate` / `startedDate` (list) vs `due_date` / `start_date` (detail).
/// - `priority` is capitalized in the list route (`High`) and lowercase in
///   the detail route (`high`). Stored lowercase everywhere.
/// - `Assignees` is capitalized in both routes.
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
  });

  final int id;
  final String name;
  final String? description;
  final String? status;

  /// Always lowercase: low | medium | high | urgent.
  final String? priority;

  final DateTime? startDate;
  final DateTime? dueDate;
  final int? projectId;
  final List<Assignee> assignees;

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawAssignees =
        (json['Assignees'] ?? json['assignees']) as List? ?? const [];

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
    );
  }

  static String? _normalizePriority(String? raw) => raw?.toLowerCase();

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
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
