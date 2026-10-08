import 'package:beemview_mobile/data/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task.fromJson', () {
    test('maps the project task list shape (camelCase dates, "High")', () {
      final task = Task.fromJson({
        'id': 501,
        'name': 'Site inspection',
        'status': 'to_do',
        'priority': 'High',
        'dueDate': null,
        'startedDate': '2026-10-06T09:00:00Z',
        'projectId': 101,
        'assignedTo': 'Candidate',
        'progress': 40, // must be ignored: progress is not part of the contract
        'Assignees': [
          {'id': 12, 'full_name': 'Candidate'},
        ],
      });

      expect(task.id, 501);
      expect(task.name, 'Site inspection');
      expect(task.status, 'to_do');
      expect(task.priority, 'high'); // normalized to lowercase
      expect(task.dueDate, isNull);
      expect(task.startDate, DateTime.parse('2026-10-06T09:00:00Z'));
      expect(task.projectId, 101);
      expect(task.assignees.single.fullName, 'Candidate');
    });

    test('maps the task details shape (snake_case dates, associations)', () {
      final task = Task.fromJson({
        'id': 501,
        'name': 'Site inspection',
        'description': 'Inspect the assigned site area',
        'status': 'in_progress',
        'priority': 'high',
        'start_date': '2026-10-06T09:00:00Z',
        'due_date': '2026-10-10T00:00:00Z',
        'project_id': 101,
        'created_at': '2026-10-05T08:00:00Z',
        'extra_field_we_do_not_know': true,
        'Project': {'id': 101, 'name': 'Interview Project'},
        'Assignees': [
          {'id': 12, 'full_name': 'Candidate'},
        ],
        'Comments': [
          {
            'id': 77,
            'content': 'Ready for inspection',
            'user': {'id': 12, 'name': 'Candidate'},
            'created_at': '2026-10-06T09:00:00Z',
          },
        ],
      });

      expect(task.description, 'Inspect the assigned site area');
      expect(task.priority, 'high');
      expect(task.startDate, DateTime.parse('2026-10-06T09:00:00Z'));
      expect(task.dueDate, DateTime.parse('2026-10-10T00:00:00Z'));
      expect(task.projectId, 101);
      expect(task.project?.name, 'Interview Project');
      expect(task.comments.single.content, 'Ready for inspection');
      expect(task.comments.single.authorName, 'Candidate');
    });

    test('tolerates null and missing optional values', () {
      final task = Task.fromJson({
        'id': 9,
        'name': 'Bare task',
        'status': null,
        'priority': null,
        'due_date': null,
        'Assignees': null,
        'Comments': null,
      });

      expect(task.status, isNull);
      expect(task.priority, isNull);
      expect(task.dueDate, isNull);
      expect(task.assignees, isEmpty);
      expect(task.comments, isEmpty);
    });
  });
}
