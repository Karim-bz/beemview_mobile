import '../../core/format.dart';

class NewTask {
  const NewTask({
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    required this.dueDate,
    required this.projectId,
    required this.isPrivate,
    required this.assigneeIds,
  });

  final String name;
  final String description;
  final String status;
  final String priority;
  final DateTime? startDate;
  final DateTime? dueDate;
  final int projectId;
  final bool isPrivate;

  /// User ids.
  final List<int> assigneeIds;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'status': status,
    'priority': priority,
    'start_date': startDate == null ? null : toApiDate(startDate!),
    'due_date': dueDate == null ? null : toApiDate(dueDate!),
    'project_id': projectId,
    'is_private': isPrivate,
    'assignees': assigneeIds,
  };
}
